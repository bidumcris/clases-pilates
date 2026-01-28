class Management::CreditsController < Management::BaseController
  before_action :ensure_admin!

  def index
    @email = params[:email].to_s.strip

    @credits = Credit.includes(:user).order(created_at: :desc)
    if @email.present?
      @credits = @credits.joins(:user).where("users.email ILIKE ?", "%#{@email}%")
    end
    @credits = @credits.where(used: params[:used]) if params[:used].present?
    @credits = @credits.where("expires_at < ?", Date.current) if params[:expired] == "1"

    # Para panel rápido: exact match (para acciones rápidas + saldo)
    @selected_student = User.find_by(email: @email.downcase, role: :alumno) if @email.present?

    # Para sugerencias y acciones por fila: matches por substring (limitado)
    @student_matches = if @email.present?
      User.where(role: :alumno).where("email ILIKE ?", "%#{@email}%").order(:email).limit(10)
    else
      []
    end
  end

  def new
    @students = User.where(role: :alumno).order(:email)
    @credit = Credit.new(expires_at: Date.current.end_of_month)
  end

  def create
    @students = User.where(role: :alumno).order(:email)
    @credit = Credit.new(credit_params)
    @credit.expires_at = Date.current.end_of_month

    if @credit.save
      redirect_to management_credits_path, notice: "Créditos agregados"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # POST /management/credits/grant
  def grant
    user = find_student_by_email!(params[:email])
    amount = params[:amount].to_i
    expires_at = Date.current.end_of_month

    if amount <= 0
      redirect_to management_credits_path(email: user.email), alert: "La cantidad debe ser mayor a 0"
      return
    end

    granted = Credit.grant_capped(user: user, amount: amount, expires_at: expires_at)
    if granted > 0
      redirect_to management_credits_path(email: user.email), notice: "Créditos otorgados (+#{granted})."
    else
      redirect_to management_credits_path(email: user.email), alert: "El alumno ya alcanzó el máximo mensual de recuperos (3)."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to management_credits_path, alert: "No existe un alumno con ese email"
  end

  # POST /management/credits/deduct
  def deduct
    user = find_student_by_email!(params[:email])
    amount_to_deduct = params[:amount].to_i

    if amount_to_deduct <= 0
      redirect_to management_credits_path(email: user.email), alert: "La cantidad debe ser mayor a 0"
      return
    end

    remaining = amount_to_deduct

    Credit.transaction do
      credits = user.credits.available.order(expires_at: :asc, created_at: :asc).lock
      credits.each do |credit|
        break if remaining <= 0

        use_now = [remaining, credit.amount].min
        credit.use!(use_now)
        remaining -= use_now
      end

      raise ActiveRecord::Rollback if remaining > 0
    end

    if remaining > 0
      redirect_to management_credits_path(email: user.email), alert: "No alcanza el saldo de créditos disponibles para descontar #{amount_to_deduct}"
    else
      redirect_to management_credits_path(email: user.email), notice: "Créditos descontados"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to management_credits_path, alert: "No existe un alumno con ese email"
  end

  private

  def find_student_by_email!(email_param)
    email = email_param.to_s.strip.downcase
    user = User.find_by(email: email, role: :alumno)
    raise ActiveRecord::RecordNotFound unless user
    user
  end

  def credit_params
    params.require(:credit).permit(:user_id, :amount, :used)
  end
end

