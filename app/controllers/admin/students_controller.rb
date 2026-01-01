class Admin::StudentsController < Admin::BaseController
  before_action :set_user, only: [:show, :edit, :update]

  def index
    @students = User.where.not(level: :admin).order(created_at: :desc)
    @students = @students.where("email ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    @students = @students.where(level: params[:level]) if params[:level].present?
    @students = @students.where(class_type: params[:class_type]) if params[:class_type].present?
  end

  def show
    @reservations = @user.reservations.includes(:pilates_class).order("pilates_classes.start_time DESC").limit(10)
    @credits = @user.credits.order(expires_at: :asc)
    @requests = @user.requests.order(created_at: :desc).limit(10)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_student_path(@user), notice: "Alumno actualizado exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def add_credits
    amount = params[:amount].to_i
    expires_at = params[:expires_at] ? Date.parse(params[:expires_at]) : Date.current.end_of_month

    credit = @user.credits.create(amount: amount, expires_at: expires_at, used: false)
    
    if credit.persisted?
      redirect_to admin_student_path(@user), notice: "#{amount} créditos agregados exitosamente"
    else
      redirect_to admin_student_path(@user), alert: "Error al agregar créditos"
    end
  end

  def update_class_type
    if @user.update(class_type: params[:class_type])
      redirect_to admin_student_path(@user), notice: "Tipo de clase actualizado exitosamente"
    else
      redirect_to admin_student_path(@user), alert: "Error al actualizar tipo de clase"
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:level, :class_type)
  end
end

