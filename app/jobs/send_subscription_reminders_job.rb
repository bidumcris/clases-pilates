class SendSubscriptionRemindersJob < ApplicationJob
  queue_as :background

  def perform(reference_date = Date.current)
    return unless ENV["BILLING_EMAIL_NOTIFICATIONS"] == "true"

    date = reference_date.is_a?(String) ? Date.parse(reference_date) : reference_date.to_date

    # 1 día antes
    Payment.subscription_fees.where(payment_status: :pending, due_date: date + 1.day).includes(:user).find_each do |payment|
      next unless payment.user&.email.present?
      BillingMailer.subscription_due_soon(payment.user, payment).deliver_later
    end

    # Primer día de vencido (para no spamear diariamente)
    Payment.subscription_fees.where(payment_status: :pending, due_date: date - 1.day).includes(:user).find_each do |payment|
      next unless payment.user&.email.present?
      BillingMailer.subscription_overdue(payment.user, payment).deliver_later
    end
  end
end

