class Management::StudentsController < Management::BaseController
  before_action :set_user, only: [ :show, :edit, :update, :abonos_modal, :credits_modal, :add_credits, :deduct_credit, :grant_recoveries, :deduct_recoveries, :update_class_type, :update_billing_status ]
  before_action :ensure_admin!, only: [ :new, :create, :edit, :update, :add_credits, :deduct_credit, :grant_recoveries, :deduct_recoveries, :update_class_type, :update_billing_status, :debtors, :absences, :birthdays ]

  def index
    @rooms = Room.order(:name)
    @students = User.where(role: :alumno).includes(fixed_slots: [ :room, :instructor ]).order(created_at: :desc)
    if params[:search].present?
      q = "%#{params[:search]}%"
      @students = @students.where("email ILIKE ? OR name ILIKE ?", q, q)
    end
    @students = @students.where(level: params[:level]) if params[:level].present?
    @students = @students.where(class_type: params[:class_type]) if params[:class_type].present?

    if current_user.instructor?
      instructor = current_user.instructor_profile
      @students = if instructor
        @students
          .joins(reservations: :pilates_class)
          .where(reservations: { status: Reservation.statuses[:confirmed] })
          .where(pilates_classes: { instructor_id: instructor.id })
          .distinct
      else
        @students.none
      end
    end
  end

  def new
    @user = User.new(role: :alumno, active: true)
    @user.join_date ||= Date.current
    @user.subscription_start ||= Date.current
    @user.subscription_end ||= Date.current.end_of_month
    @rooms = Room.order(:name)
    @instructors = Instructor.order(:name)
  end

  def create
    @user = User.new(student_create_params)
    @user.role = :alumno
    @user.level ||= :basic
    @user.class_type ||= :grupal
    @user.join_date ||= Date.current
    @user.subscription_start ||= @user.join_date
    @user.subscription_end ||= (@user.subscription_start&.end_of_month)

    if @user.save
      create_fixed_slot_if_present
      redirect_to management_student_path(@user), notice: "Alumno creado exitosamente"
    else
      @rooms = Room.order(:name)
      @instructors = Instructor.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # Períodos para el selector (pagos de cuota con period_start/end)
    @periods = @user.payments.subscription_fees
      .where.not(period_start: nil, period_end: nil)
      .order(period_start: :desc)
      .limit(24)
      .map { |p| { payment: p, period_start: p.period_start, period_end: p.period_end, amount: p.amount } }

    # Si no hay pagos con período, usar mes actual desde subscription
    if @periods.empty? && @user.subscription_start.present? && @user.subscription_end.present?
      start_d = @user.subscription_start.to_date
      end_d = @user.subscription_end.to_date
      @periods = [ { payment: nil, period_start: start_d, period_end: end_d, amount: @user.payment_amount || 0 } ]
    elsif @periods.empty?
      start_d = Date.current.beginning_of_month
      end_d = Date.current.end_of_month
      @periods = [ { payment: nil, period_start: start_d, period_end: end_d, amount: @user.payment_amount || 0 } ]
    end

    # Período seleccionado (params period = "YYYY-MM" o primero de la lista)
    period_key = params[:period].presence
    if period_key.present? && period_key.match?(/\A\d{4}-\d{2}\z/)
      y, m = period_key.split("-").map(&:to_i)
      sel_start = Date.new(y, m, 1)
      sel_end = sel_start.end_of_month
      @selected_period = @periods.find { |h| h[:period_start] == sel_start && h[:period_end] == sel_end } || @periods.first
    else
      @selected_period = @periods.first
    end

    range = @selected_period[:period_start].beginning_of_day..@selected_period[:period_end].end_of_day

    # Turnos del mes (reservas en el período)
    @turnos_mes = @user.reservations
      .joins(:pilates_class)
      .where(pilates_classes: { start_time: range })
      .includes(pilates_class: [ :room, :instructor ])
      .order("pilates_classes.start_time ASC")

    # Período de renovación: próximo mes (clases que coinciden con turnos fijos del usuario)
    next_start = (@selected_period[:period_end] + 1.day).to_date
    next_end = next_start.end_of_month
    renov_range = next_start.beginning_of_day..next_end.end_of_day
    @turnos_renovacion = clases_en_rango_para_usuario(@user, renov_range)

    # Turnos fuera de alcance: mes siguiente al de renovación
    after_start = (next_end + 1.day).to_date
    after_end = after_start.end_of_month
    fuera_range = after_start.beginning_of_day..after_end.end_of_day
    @turnos_fuera_alcance = clases_en_rango_para_usuario(@user, fuera_range)

    # Eventos recientes (pagos + reservas por fecha)
    @eventos_recientes = build_eventos_recientes(@user, limit: 20)

    # Para tabs Créditos y Solicitudes
    @credits = @user.credits.order(expires_at: :asc)
    @requests = @user.requests.includes(:pilates_class).order(created_at: :desc).limit(20)
    @payments = @user.payments.order(created_at: :desc).limit(20)
  end

  def edit
  end

  def abonos_modal
    render partial: "abonos_modal_content", layout: false
  end

  def credits_modal
    @rooms = Room.order(:name)
    @credits = @user.credits.available.includes(:room).order(expires_at: :asc, created_at: :asc)
    render partial: "credits_modal_content", layout: false
  end

  def update
    if @user.update(user_params)
      redirect_to management_student_path(@user), notice: "Alumno actualizado exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_billing_status
    status = params[:billing_status]
    unless User.billing_statuses.key?(status)
      redirect_to management_student_path(@user), alert: "Estado inválido" and return
    end
    @user.update!(billing_status: status)
    redirect_to management_student_path(@user), notice: "Estado de pago actualizado"
  end

  def add_credits
    amount = params[:amount].to_i
    expires_at = Date.current.end_of_month

    granted = Credit.grant_capped(user: @user, amount: amount, expires_at: expires_at)
    if granted > 0
      redirect_to management_student_path(@user), notice: "Recuperos otorgados (+#{granted})."
    else
      redirect_to management_student_path(@user), alert: "El alumno ya alcanzó el máximo mensual de recuperos (3)."
    end
  end

  # POST /management/students/:id/grant_recoveries
  def grant_recoveries
    amount = params[:amount].to_i
    expires_at = Date.current.end_of_month
    room = params[:room_id].present? ? Room.find_by(id: params[:room_id]) : nil

    if amount <= 0
      redirect_back fallback_location: edit_management_student_path(@user), alert: "La cantidad debe ser mayor a 0"
      return
    end

    granted = Credit.grant_capped(user: @user, amount: amount, expires_at: expires_at, room: room)
    if granted > 0
      redirect_back fallback_location: management_students_path, notice: "Recuperos otorgados (+#{granted})."
    else
      redirect_back fallback_location: management_students_path, alert: "El alumno ya alcanzó el máximo mensual de recuperos (3) para esa sala."
    end
  end

  # POST /management/students/:id/deduct_credit (quita 1 recupero de un crédito concreto)
  def deduct_credit
    credit = @user.credits.available.find_by(id: params[:credit_id])
    unless credit
      redirect_back fallback_location: management_students_path, alert: "Crédito no encontrado."
      return
    end
    credit.use!(1)
    redirect_back fallback_location: management_students_path, notice: "Recupero descontado."
  end

  # POST /management/students/:id/deduct_recoveries
  def deduct_recoveries
    amount_to_deduct = params[:amount].to_i

    if amount_to_deduct <= 0
      redirect_back fallback_location: edit_management_student_path(@user), alert: "La cantidad debe ser mayor a 0"
      return
    end

    remaining = amount_to_deduct

    Credit.transaction do
      credits = @user.credits.available_this_month.order(expires_at: :asc, created_at: :asc).lock
      credits.each do |credit|
        break if remaining <= 0

        use_now = [ remaining, credit.amount ].min
        credit.use!(use_now)
        remaining -= use_now
      end

      raise ActiveRecord::Rollback if remaining > 0
    end

    if remaining > 0
      redirect_back fallback_location: edit_management_student_path(@user), alert: "No alcanza el saldo de recuperos disponibles para descontar #{amount_to_deduct}."
    else
      redirect_back fallback_location: edit_management_student_path(@user), notice: "Recuperos descontados (-#{amount_to_deduct})."
    end
  end

  # POST /management/students/:id/send_whatsapp_test
  def send_whatsapp_test
    unless @user.whatsapp_opt_in?
      redirect_back fallback_location: edit_management_student_path(@user), alert: "El alumno no tiene opt-in de WhatsApp."
      return
    end

    to = @user.mobile_e164_ar
    if to.blank?
      redirect_back fallback_location: edit_management_student_path(@user), alert: "El alumno no tiene un número válido para WhatsApp."
      return
    end

    client = Whatsapp::Client.new
    unless client.enabled?
      redirect_back fallback_location: edit_management_student_path(@user), alert: "WhatsApp Cloud API no está configurado en el servidor."
      return
    end

    template = ENV.fetch("WHATSAPP_TEMPLATE_TEST", "subscription_due_soon")
    client.send_template(
      to: to,
      template_name: template,
      language: ENV.fetch("WHATSAPP_TEMPLATE_LANGUAGE", "es_AR"),
      variables: [ @user.name.presence || "alumna/o", Date.current.strftime("%d/%m"), (@user.payment_amount || 0).to_s ]
    )

    redirect_back fallback_location: edit_management_student_path(@user), notice: "WhatsApp de prueba enviado (si el template está configurado)."
  rescue => e
    redirect_back fallback_location: edit_management_student_path(@user), alert: "Error enviando WhatsApp: #{e.message}"
  end

  def update_class_type
    if @user.update(class_type: params[:class_type])
      redirect_to management_student_path(@user), notice: "Tipo de clase actualizado exitosamente"
    else
      redirect_to management_student_path(@user), alert: "Error al actualizar tipo de clase"
    end
  end

  def debtors
    @students = User.where(role: :alumno, active: true)
                    .where("COALESCE(debt_amount, 0) > 0")
                    .order(Arel.sql("debt_amount DESC"))
  end

  def absences
    range = Time.zone.now.beginning_of_month.beginning_of_day..Time.zone.now.end_of_month.end_of_day

    counts =
      Reservation
        .joins(:pilates_class)
        .where(status: :cancelled, pilates_classes: { start_time: range })
        .group(:user_id)
        .count

    @min_cancellations = 2
    user_ids = counts.select { |_id, c| c > @min_cancellations }.keys
    @cancellations_by_user_id = counts
    @students = User.where(id: user_ids).order(:name, :email)
  end

  def birthdays
    month = Date.current.month
    @students = User.where(role: :alumno, active: true)
                    .where("birth_date IS NOT NULL AND EXTRACT(MONTH FROM birth_date) = ?", month)
                    .order(Arel.sql("EXTRACT(DAY FROM birth_date) ASC"))
  end

  private

  def set_user
    @user = User.find(params[:id])

    if current_user.instructor?
      instructor = current_user.instructor_profile
      allowed = instructor && @user.reservations.joins(:pilates_class).where(status: :confirmed, pilates_classes: { instructor_id: instructor.id }).exists?
      unless allowed
        flash[:alert] = "No tienes acceso a este alumno"
        redirect_to management_students_path
      end
    end
  end

  def user_params
    params.require(:user).permit(
      :role, :level, :class_type, :dni, :phone, :mobile, :birth_date, :email,
      :name, :active, :fake_email,
      :subscription_start, :subscription_end,
      :emergency_phone, :additional_info,
      :payment_amount, :debt_amount, :last_payment_date,
      :billing_status,
      :monthly_turns, :join_date, :first_payment_date, :payments_count,
      :whatsapp_opt_in, :whatsapp_opt_in_at, :whatsapp_opt_in_source,
      :normal_view, :param1, :param2, :param3,
      weekly_days: []
    )
  end

  def student_create_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      :name, :dni, :phone, :mobile, :birth_date,
      :level, :class_type, :active,
      :join_date, :subscription_start, :subscription_end,
      :payment_amount, :debt_amount, :monthly_turns,
      weekly_days: []
    )
  end

  def create_fixed_slot_if_present
    room_ids = Array(params[:fixed_slot_room_id])
    instructor_ids = Array(params[:fixed_slot_instructor_id])
    day_of_weeks = Array(params[:fixed_slot_day_of_week])
    hours = Array(params[:fixed_slot_hour])
    default_instructor_id = Instructor.order(:id).first&.id

    room_ids.each_with_index do |room_id, i|
      room_id = room_id.presence
      day_of_week = day_of_weeks[i].presence
      hour = hours[i].presence
      next unless room_id.present? && day_of_week.present? && hour.present?

      room = Room.find_by(id: room_id)
      next unless room

      instructor_id = instructor_ids[i].presence || default_instructor_id
      next unless instructor_id.present?

      @user.fixed_slots.create!(
        room_id: room.id,
        instructor_id: instructor_id,
        day_of_week: day_of_week.to_i,
        hour: hour.to_i,
        level: @user.level
      )
    end
  rescue ActiveRecord::RecordInvalid
    # No bloquear la creación del alumno si falla algún turno fijo
  end

  # Clases en el rango de fechas que coinciden con los turnos fijos del usuario (mismo room, instructor, level, día, hora)
  def clases_en_rango_para_usuario(user, range)
    return [] unless user.grupal? && user.fixed_slots.active.any?

    slots = user.fixed_slots.active.includes(:room, :instructor)
    clases = slots.flat_map do |slot|
      PilatesClass
        .includes(:room, :instructor)
        .where(
          class_type: :grupal,
          room_id: slot.room_id,
          instructor_id: slot.instructor_id,
          level: slot.level,
          start_time: range
        )
        .where(
          "EXTRACT(DOW FROM start_time) = ? AND EXTRACT(HOUR FROM start_time) = ?",
          slot.day_of_week,
          slot.hour
        )
    end
    clases.uniq(&:id).sort_by(&:start_time)
  end

  def build_eventos_recientes(user, limit: 20)
    eventos = []
    user.payments.order(created_at: :desc).limit(limit).each do |p|
      eventos << {
        type: :payment,
        date: p.created_at,
        label: "Pago #{p.completed? ? 'completado' : p.payment_status}",
        amount: p.amount,
        period: (p.period_start && p.period_end) ? "#{p.period_start.strftime('%d/%m')} al #{p.period_end.strftime('%d/%m')}" : nil
      }
    end
    user.reservations.joins(:pilates_class).order("reservations.created_at DESC").limit(limit).each do |r|
      eventos << {
        type: :reservation,
        date: r.reserved_at || r.created_at,
        label: "Reserva #{r.status}",
        class_name: r.pilates_class.name,
        start_time: r.pilates_class.start_time
      }
    end
    eventos.sort_by { |e| e[:date] }.reverse.first(limit)
  end
end
