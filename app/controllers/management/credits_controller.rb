class Management::CreditsController < Management::BaseController
  before_action :ensure_admin!

  def index
    @students = User.where(role: :alumno).order(:email)

    @credits = Credit.includes(:user).order(created_at: :desc)
    @credits = @credits.where(user_id: params[:user_id]) if params[:user_id].present?
    @credits = @credits.where(used: params[:used]) if params[:used].present?
    @credits = @credits.where("expires_at < ?", Date.current) if params[:expired] == "1"
  end

  def new
    @students = User.where(role: :alumno).order(:email)
    @credit = Credit.new(expires_at: Date.current.end_of_month)
  end

  def create
    @students = User.where(role: :alumno).order(:email)
    @credit = Credit.new(credit_params)

    if @credit.save
      redirect_to management_credits_path, notice: "Créditos agregados"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def credit_params
    params.require(:credit).permit(:user_id, :amount, :expires_at, :used)
  end
end

