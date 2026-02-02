# frozen_string_literal: true

class Management::AttendanceController < Management::BaseController
  def index
    @rooms = Room.order(:name)
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @room_id = params[:room_id].presence
    @room_id = @rooms.first.id if @room_id.blank? && @rooms.any?

    if @room_id.present?
      range = @date.beginning_of_day..@date.end_of_day
      @classes = PilatesClass
        .includes(:room, :instructor, reservations: :user)
        .where(room_id: @room_id, start_time: range)
        .order(:start_time)
    else
      @classes = []
    end

    # Panel derecho: Autogestion (turnos recientes/cancelados, pagos)
    @recent_reservations = Reservation
      .includes(:user, pilates_class: :room)
      .where(status: [ :confirmed, :cancelled ])
      .order(updated_at: :desc)
      .limit(20)
    @recent_payments = Payment
      .includes(:user)
      .order(updated_at: :desc)
      .limit(15)
  end
end
