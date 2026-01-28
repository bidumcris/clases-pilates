class SendSubscriptionRemindersJob < ApplicationJob
  queue_as :background

  def perform(reference_date = Date.current)
    email_enabled = ENV["BILLING_EMAIL_NOTIFICATIONS"] == "true"
    whatsapp_enabled = ENV["BILLING_WHATSAPP_NOTIFICATIONS"] == "true"
    client = whatsapp_enabled ? Whatsapp::Client.new : nil
    whatsapp_enabled = false if client && !client.enabled?

    date = reference_date.is_a?(String) ? Date.parse(reference_date) : reference_date.to_date

    # 1 día antes
    Payment.subscription_fees.where(payment_status: :pending, due_date: date + 1.day).includes(:user).find_each do |payment|
      user = payment.user
      next unless user

      if email_enabled && user.email.present?
        BillingMailer.subscription_due_soon(user, payment).deliver_later
      end

      if whatsapp_enabled && user.whatsapp_opt_in? && user.mobile_e164_ar.present?
        template = ENV.fetch("WHATSAPP_TEMPLATE_SUBSCRIPTION_DUE_SOON", "subscription_due_soon")
        client.send_template(
          to: user.mobile_e164_ar,
          template_name: template,
          language: ENV.fetch("WHATSAPP_TEMPLATE_LANGUAGE", "es_AR"),
          variables: [
            user.name.presence || "alumna/o",
            payment.due_date.strftime("%d/%m"),
            payment.amount.to_s
          ]
        )
      end
    end

    # Primer día de vencido (para no spamear diariamente)
    Payment.subscription_fees.where(payment_status: :pending, due_date: date - 1.day).includes(:user).find_each do |payment|
      user = payment.user
      next unless user

      if email_enabled && user.email.present?
        BillingMailer.subscription_overdue(user, payment).deliver_later
      end

      if whatsapp_enabled && user.whatsapp_opt_in? && user.mobile_e164_ar.present?
        template = ENV.fetch("WHATSAPP_TEMPLATE_SUBSCRIPTION_OVERDUE", "subscription_overdue")
        client.send_template(
          to: user.mobile_e164_ar,
          template_name: template,
          language: ENV.fetch("WHATSAPP_TEMPLATE_LANGUAGE", "es_AR"),
          variables: [
            user.name.presence || "alumna/o",
            payment.due_date.strftime("%d/%m"),
            payment.amount.to_s
          ]
        )
      end
    end
  end
end

