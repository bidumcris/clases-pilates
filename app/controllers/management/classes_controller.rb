class Management::ClassesController < Management::BaseController
  before_action :set_pilates_class, only: [ :edit, :update, :destroy, :attendance, :update_attendance, :mark_holiday, :unmark_holiday ]
  before_action :ensure_admin!, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :ensure_can_take_attendance!, only: [ :attendance, :update_attendance ]
  before_action :ensure_admin!, only: [ :mark_holiday, :unmark_holiday ]
  before_action :ensure_admin!, only: [ :block, :create_block ]

  def index
    @view_mode = params[:view].presence_in(%w[week today]) || "week"
    @room_id = params[:room_id].presence

    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @date = Date.current if @view_mode == "today"

    @week_start = (@view_mode == "today") ? @date : @date.beginning_of_week(:monday)
    @week_end = (@view_mode == "today") ? @date : (@week_start + 6.days)

    @classes = PilatesClass.where("DATE(start_time) >= ? AND DATE(start_time) <= ?", @week_start, @week_end)
                           .order(start_time: :asc)
    @classes = @classes.where(room_id: @room_id) if @room_id.present?
    if current_user.instructor?
      instructor = current_user.instructor_profile
      @classes = instructor ? @classes.where(instructor_id: instructor.id) : @classes.none
    end
    @classes_by_day = @classes.group_by { |c| c.start_time.to_date }

    class_ids = @classes.pluck(:id)
    @booked_counts =
      if class_ids.any?
        Reservation.where(status: :confirmed, pilates_class_id: class_ids).group(:pilates_class_id).count
      else
        {}
      end

    @rooms = Room.all
    @instructors = Instructor.all
  end

  def new
    @pilates_class = PilatesClass.new
    @rooms = Room.all
    @instructors = Instructor.all
    # Valores por defecto
    @pilates_class.start_time = Time.current.beginning_of_hour + 1.hour
    # end_time se calcula automáticamente al guardar (+1 hora) si queda vacío
    @pilates_class.max_capacity = 10
    @pilates_class.level = :basic
    @pilates_class.class_type = :grupal
  end

  def create
    @pilates_class = PilatesClass.new(pilates_class_params)
    @rooms = Room.all
    @instructors = Instructor.all

    normalize_class_times_and_capacity

    if @pilates_class.save
      redirect_to management_classes_path, notice: "Clase creada exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @rooms = Room.all
    @instructors = Instructor.all
  end

  def update
    @pilates_class.assign_attributes(pilates_class_params)
    normalize_class_times_and_capacity

    if @pilates_class.save
      redirect_to management_classes_path, notice: "Clase actualizada exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @pilates_class.destroy
    redirect_to management_classes_path, notice: "Clase eliminada exitosamente"
  end

  def mark_holiday
    reason = params[:holiday_reason].to_s.strip.presence
    apply_block_to_classes!([@pilates_class], reason: reason.presence || "Feriado")
    redirect_to management_classes_path, notice: "Clase marcada como feriado. Se otorgó 1 recupero a los alumnos afectados."
  end

  def unmark_holiday
    @pilates_class.update!(holiday: false, holiday_reason: nil)
    redirect_to management_classes_path, notice: "Clase desmarcada como feriado."
  end

  # Bloqueo por rango (día completo o horario) y por sala o todas
  def block
    @rooms = Room.order(:name)
    @block_date = Date.current
  end

  def create_block
    date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    scope = params[:scope].presence_in(%w[all one]) || "all"
    room_id = (scope == "one") ? params[:room_id].presence : nil

    mode = params[:mode].presence_in(%w[full_day time_range]) || "full_day"
    reason = params[:reason].to_s.strip.presence || "Bloqueo"

    start_at =
      if mode == "full_day"
        Time.zone.parse("#{date} 00:00")
      else
        Time.zone.parse("#{date} #{params[:start_time].presence || '00:00'}")
      end

    end_at =
      if mode == "full_day"
        Time.zone.parse("#{date} 23:59")
      else
        Time.zone.parse("#{date} #{params[:end_time].presence || '23:59'}")
      end

    if end_at <= start_at
      redirect_to block_management_classes_path, alert: "Rango horario inválido"
      return
    end

    classes = PilatesClass.where("start_time < ? AND end_time > ?", end_at, start_at)
    classes = classes.where(room_id: room_id) if room_id.present?

    apply_block_to_classes!(classes.to_a, reason: reason)
    redirect_to management_classes_path(view: "week"), notice: "Bloqueo aplicado. Se otorgó 1 recupero por alumno afectado."
  rescue Date::Error
    redirect_to block_management_classes_path, alert: "Fecha inválida"
  end

  def calendar
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @week_start = @date.beginning_of_week(:monday)
    @week_end = @week_start + 6.days

    @classes = PilatesClass.where("DATE(start_time) >= ? AND DATE(start_time) <= ?", @week_start, @week_end)
                           .order(start_time: :asc)
    @classes_by_day = @classes.group_by { |c| c.start_time.to_date }
  end

  def attendance
    @reservations = @pilates_class.reservations.includes(:user).where(status: :confirmed).order("users.email ASC")
    @present_count = @reservations.where(attendance_status: :presente).count
    @absent_count = @reservations.where(attendance_status: :ausente).count
    @unmarked_count = @reservations.where(attendance_status: :sin_marcar).count
  end

  def update_attendance
    updates = params.fetch(:attendance, {}).to_h

    Reservation.transaction do
      @pilates_class.reservations.where(status: :confirmed).find_each do |reservation|
        next unless updates.key?(reservation.id.to_s)

        status = updates[reservation.id.to_s]
        next unless Reservation.attendance_statuses.key?(status)

        reservation.update!(attendance_status: status)
      end
    end

    redirect_to attendance_management_class_path(@pilates_class), notice: "Lista actualizada"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to attendance_management_class_path(@pilates_class), alert: e.record.errors.full_messages.join(", ")
  end

  private

  def set_pilates_class
    @pilates_class = PilatesClass.find_by(id: params[:id])
    return if @pilates_class.present?

    redirect_to management_classes_path, alert: "Clase no encontrada" and return
  end

  def ensure_can_take_attendance!
    return if current_user.admin?

    if current_user.instructor?
      instructor = current_user.instructor_profile
      return if instructor && @pilates_class.instructor_id == instructor.id
    end

    flash[:alert] = "No tienes acceso a esta clase"
    redirect_to management_classes_path
  end

  def normalize_class_times_and_capacity
    if @pilates_class.start_time.present? && @pilates_class.end_time.blank?
      @pilates_class.end_time = @pilates_class.start_time + 1.hour
    end

    if @pilates_class.privada?
      @pilates_class.max_capacity = 1
      @pilates_class.room ||= Room.private_enabled.first
    elsif @pilates_class.room && @pilates_class.max_capacity.blank?
      @pilates_class.max_capacity = @pilates_class.room.capacity
    end
  end

  def pilates_class_params
    params.require(:pilates_class).permit(:name, :tags, :level, :class_type, :room_id, :instructor_id, :start_time, :end_time, :max_capacity, :holiday, :holiday_reason)
  end

  def apply_block_to_classes!(classes, reason:)
    return if classes.blank?

    classes.each do |klass|
      klass.update!(holiday: true, holiday_reason: reason)

      expires_at = klass.start_time.in_time_zone.to_date.end_of_month
      klass.reservations.where(status: :confirmed).includes(:user).find_each do |reservation|
        Credit.create!(user: reservation.user, amount: 1, expires_at: expires_at, used: false)
        reservation.update!(status: :cancelled, attendance_status: :sin_marcar)
      end
    end
  end
end
