class Management::StudentsController < Management::BaseController
  before_action :set_user, only: [ :show, :edit, :update, :add_credits, :update_class_type ]
  before_action :ensure_admin!, only: [ :edit, :update, :add_credits, :update_class_type ]

  def index
    @students = User.where(role: :alumno).order(created_at: :desc)
    @students = @students.where("email ILIKE ?", "%#{params[:search]}%") if params[:search].present?
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

    credit = @user.credits.create(amount: amount, expires_at: expires_at, used: false)

    if credit.persisted?
      redirect_to management_student_path(@user), notice: "#{amount} créditos agregados exitosamente"
    else
      redirect_to management_student_path(@user), alert: "Error al agregar créditos"
    end
  end

  def update_class_type
    if @user.update(class_type: params[:class_type])
      redirect_to management_student_path(@user), notice: "Tipo de clase actualizado exitosamente"
    else
      redirect_to management_student_path(@user), alert: "Error al actualizar tipo de clase"
    end
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
      :monthly_turns, :join_date, :first_payment_date, :payments_count,
      :normal_view, :param1, :param2, :param3
    )
  end
end
