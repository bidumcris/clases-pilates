class Management::BillingController < Management::BaseController
  before_action :ensure_admin!

  def debtors
    @status = params[:status].presence_in(%w[overdue due_soon pending all]) || "overdue"
    @q = params[:q].to_s.strip.downcase

    month_start = Date.current.beginning_of_month
    month_end = Date.current.end_of_month

    base = Payment.subscription_fees
                  .includes(:user)
                  .where("period_start <= ? AND period_end >= ?", month_end, month_start)

    base = case @status
    when "overdue"
      base.overdue
    when "due_soon"
      base.due_soon(days: 1)
    when "pending"
      base.pending
    else
      base
    end

    if @q.present?
      base = base.joins(:user).where("LOWER(users.email) LIKE ? OR LOWER(users.name) LIKE ?", "%#{@q}%", "%#{@q}%")
    end

    @payments = base.order(due_date: :asc, created_at: :desc).limit(500)
    @total_amount = @payments.sum(&:amount)
    @count = @payments.size
  end
end

