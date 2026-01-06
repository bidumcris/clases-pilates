class Management::CashboxController < Management::BaseController
  before_action :ensure_admin!

  def index
    @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current.beginning_of_month
    @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current.end_of_month
    range = @start_date.beginning_of_day..@end_date.end_of_day

    @payments = Payment
      .includes(:user)
      .where(created_at: range)
      .order(created_at: :desc)

    completed = @payments.select { |p| p.completed? }
    @totals_by_method = completed.group_by(&:payment_method).transform_values { |ps| ps.sum(&:amount) }
    @total_completed = completed.sum(&:amount)
    @count_completed = completed.count
  rescue Date::Error
    redirect_to management_cashbox_path, alert: "Fechas inválidas"
  end

  def create_payment
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    unless user
      redirect_to management_cashbox_path, alert: "No existe un usuario con ese email"
      return
    end

    payment = Payment.new(
      user: user,
      amount: params[:amount],
      payment_method: params[:payment_method],
      payment_status: params[:payment_status].presence || "completed",
      transaction_id: params[:transaction_id].presence
    )

    if payment.save
      redirect_to management_cashbox_path, notice: "Pago registrado"
    else
      redirect_to management_cashbox_path, alert: payment.errors.full_messages.join(", ")
    end
  end
end


