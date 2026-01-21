class GenerateSubscriptionFeesJob < ApplicationJob
  queue_as :background

  def perform(reference_date = Date.current)
    date = reference_date.is_a?(String) ? Date.parse(reference_date) : reference_date.to_date
    return unless date.day == 1

    period_start = date.beginning_of_month
    period_end = date.end_of_month
    due_date = date.change(day: 10)

    scope = User.where(role: :alumno)
    scope = scope.where(active: true) if User.column_names.include?("active")

    scope.find_each do |user|
      next unless user.payment_amount.present? && user.payment_amount.to_f.positive?

      # Suscripción activa por fechas (si están cargadas)
      if user.subscription_start.present? && user.subscription_start.to_date > period_end
        next
      end
      if user.subscription_end.present? && user.subscription_end.to_date < period_start
        next
      end

      Payment.find_or_create_by!(user: user, kind: :subscription_fee, period_start: period_start, period_end: period_end) do |p|
        p.amount = user.payment_amount
        p.payment_method = :efectivo # default (se puede pagar por MP u otro luego)
        p.payment_status = :pending
        p.due_date = due_date
        p.turns_included = user.monthly_turns
        p.notes = "Cuota automática #{period_start.strftime('%m/%Y')}"
      end
    end
  end
end

