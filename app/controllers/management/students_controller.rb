class Management::StudentsController < Management::BaseController
  before_action :set_user, only: [ :show, :edit, :update, :add_credits, :grant_recoveries, :deduct_recoveries, :update_class_type ]
  before_action :ensure_admin!, only: [ :new, :create, :edit, :update, :add_credits, :grant_recoveries, :deduct_recoveries, :update_class_type, :debtors, :absences, :birthdays ]

  def index
    @students = User.where(role: :alumno).order(created_at: :desc)
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
      redirect_to management_student_path(@user), notice: "Alumno creado exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @reservations = @user.reservations.includes(:pilates_class).order("pilates_classes.start_time DESC").limit(10)
    @credits = @user.credits.order(expires_at: :asc)
    @requests = @user.requests.order(created_at: :desc).limit(10)
    @payments = @user.payments.order(created_at: :desc).limit(20)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to management_student_path(@user), notice: "Alumno actualizado exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
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

    if amount <= 0
      redirect_back fallback_location: edit_management_student_path(@user), alert: "La cantidad debe ser mayor a 0"
      return
    end

    granted = Credit.grant_capped(user: @user, amount: amount, expires_at: expires_at)
    if granted > 0
      redirect_back fallback_location: edit_management_student_path(@user), notice: "Recuperos otorgados (+#{granted})."
    else
      redirect_back fallback_location: edit_management_student_path(@user), alert: "El alumno ya alcanzó el máximo mensual de recuperos (3)."
    end
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

        use_now = [remaining, credit.amount].min
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
      variables: [@user.name.presence || "alumna/o", Date.current.strftime("%d/%m"), (@user.payment_amount || 0).to_s]
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
end
