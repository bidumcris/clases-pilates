class BillingMailer < ApplicationMailer
  def subscription_due_soon(user, payment)
    @user = user
    @payment = payment
    mail(to: @user.email, subject: "Tu cuota vence el #{@payment.due_date.strftime('%d/%m')}")
  end

  def subscription_overdue(user, payment)
    @user = user
    @payment = payment
    mail(to: @user.email, subject: "Tu cuota está vencida (venció el #{@payment.due_date.strftime('%d/%m')})")
  end
end

