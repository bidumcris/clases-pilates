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

    # Integración por sala: ocupación de clases (no dinero).
    classes_in_range = PilatesClass.where(start_time: range)
    @classes_count_by_room = classes_in_range.group(:room_id).count
    @capacity_sum_by_room = classes_in_range.group(:room_id).sum(:max_capacity)

    reservations_in_range =
      Reservation
        .joins(:pilates_class)
        .where(status: :confirmed, pilates_classes: { start_time: range })

    @reservations_count_by_room = reservations_in_range.group("pilates_classes.room_id").count
    @present_count_by_room =
      reservations_in_range
        .where(attendance_status: Reservation.attendance_statuses[:presente])
        .group("pilates_classes.room_id")
        .count

    @rooms = Room.order(:name)
  rescue Date::Error
    redirect_to management_cashbox_path, alert: "Fechas inválidas"
  end

  def create_payment
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    unless user
      redirect_to management_cashbox_path, alert: "No existe un usuario con ese email"
      return
    end

    payment_method = params[:payment_method].to_s
    kind = params[:kind].presence_in(Payment.kinds.keys) || "manual"
    period_start = params[:period_start].present? ? Date.parse(params[:period_start]) : nil
    period_end = params[:period_end].present? ? Date.parse(params[:period_end]) : nil
    due_date = params[:due_date].present? ? Date.parse(params[:due_date]) : nil
    turns_included = params[:turns_included].presence&.to_i

    if payment_method == "mercado_pago"
      payment = Payment.new(
        user: user,
        amount: params[:amount],
        payment_method: :mercado_pago,
        payment_status: :pending,
        provider: "mercado_pago",
        kind: kind,
        period_start: period_start,
        period_end: period_end,
        due_date: due_date,
        turns_included: turns_included
      )

      unless payment.save
        redirect_to management_cashbox_path, alert: payment.errors.full_messages.join(", ")
        return
      end

      client = MercadoPago::Client.new
      unless client.configured?
        payment.update(payment_status: :failed, provider_payload: { error: "not_configured" })
        redirect_to management_cashbox_path, alert: "Falta configurar MERCADOPAGO_ACCESS_TOKEN"
        return
      end

      # IMPORTANTE: Mercado Pago NO puede notificar a localhost. En producción esto funciona directo.
      notification_url =
        ENV["MERCADOPAGO_WEBHOOK_URL"].presence ||
        webhooks_mercado_pago_url(host: request.host, port: request.optional_port, protocol: request.protocol)

      title = params[:title].presence || "Cuota Energía Pilates (#{user.email})"

      pref = client.create_preference(
        external_reference: payment.id,
        title: title,
        unit_price: payment.amount,
        payer_email: user.email,
        notification_url: notification_url
      )

      checkout_url = (ENV["MERCADOPAGO_USE_SANDBOX"] == "true") ? pref["sandbox_init_point"] : pref["init_point"]

      payment.update!(
        provider_reference: payment.id.to_s,
        transaction_id: pref["id"].to_s, # preference id
        checkout_url: checkout_url.to_s,
        provider_payload: pref
      )

      redirect_to management_cashbox_path, notice: "Link Mercado Pago generado (copiá y envialo): #{payment.checkout_url}"
      return
    end

    payment = Payment.new(
      user: user,
      amount: params[:amount],
      payment_method: payment_method,
      payment_status: params[:payment_status].presence || "completed",
      transaction_id: params[:transaction_id].presence,
      kind: kind,
      period_start: period_start,
      period_end: period_end,
      due_date: due_date,
      turns_included: turns_included
    )

    if payment.save
      redirect_to management_cashbox_path, notice: "Pago registrado"
    else
      redirect_to management_cashbox_path, alert: payment.errors.full_messages.join(", ")
    end
  rescue Date::Error
    redirect_to management_cashbox_path, alert: "Fechas inválidas"
  end
end


