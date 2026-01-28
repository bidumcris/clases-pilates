class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @reservations = current_user.reservations.upcoming.limit(5)
    # Recuperos: son mensuales (no se acumulan entre meses)
    @credits = current_user.credits.available_this_month
    @recoveries_this_month_total = @credits.sum(:amount)
    @recoveries_monthly_cap = 3

    # Clases fijas del mes (para alumnos con turnos fijos)
    month_start = Date.current.beginning_of_month
    month_end = Date.current.end_of_month
    @fixed_classes_month = []

    if current_user.grupal? && current_user.fixed_slots.active.any?
      range = month_start.beginning_of_day..month_end.end_of_day

      fixed_classes =
        current_user.fixed_slots.active.includes(:room, :instructor).flat_map do |slot|
          PilatesClass
            .includes(:room, :instructor)
            .where(
              class_type: :grupal,
              room_id: slot.room_id,
              instructor_id: slot.instructor_id,
              level: slot.level,
              start_time: range
            )
            .where(
              "EXTRACT(DOW FROM start_time) = ? AND EXTRACT(HOUR FROM start_time) = ?",
              slot.day_of_week,
              slot.hour
            )
        end

      @fixed_classes_month = fixed_classes.uniq(&:id).sort_by(&:start_time)
    end

    @current_subscription_fee =
      current_user.payments.subscription_fees
                  .for_period(month_start, month_end)
                  .order(created_at: :desc)
                  .first
  end

  def mi_actividad
    @user = current_user
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @reservations = current_user.reservations.by_month(@date)
  end
end
