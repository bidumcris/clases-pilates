# frozen_string_literal: true

class Management::AttendanceController < Management::BaseController
  def index
    @rooms = Room.order(:name)
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @room_id = params[:room_id].presence
    @room_id = @rooms.first.id if @room_id.blank? && @rooms.any?

    # Instructores: solo ven sus clases; solo pueden ver el día siguiente si ya tomaron asistencia de hoy
    @instructor = current_user.instructor? ? current_user.instructor_profile : nil
    if @instructor
      @rooms = @rooms.joins(:pilates_classes).where(pilates_classes: { instructor_id: @instructor.id }).distinct
      @room_id = @rooms.first.id if @room_id.present? && @rooms.any? && !@rooms.where(id: @room_id).exists?
      @room_id = @rooms.first.id if @room_id.blank? && @rooms.any?

      if @date > Date.current
        unless @date == Date.current + 1.day && @instructor.today_attendance_complete?
          @date = Date.current
          flash.now[:alert] = "Completá la asistencia de hoy para poder ver el listado del día siguiente."
        end
      end
    end

    if @room_id.present?
      range = @date.beginning_of_day..@date.end_of_day
      @classes = PilatesClass
        .includes(:room, :instructor, reservations: :user)
        .where(room_id: @room_id, start_time: range)
        .order(:start_time)
      @classes = @classes.where(instructor_id: @instructor.id) if @instructor
    else
      @classes = []
    end

    # Panel derecho: Autogestion (turnos recientes/cancelados, pagos) — solo para admin o si se quiere mostrar siempre
    @recent_reservations = Reservation
      .includes(:user, pilates_class: :room)
      .where(status: [ :confirmed, :cancelled ])
      .order(updated_at: :desc)
      .limit(20)
    @recent_reservations = @recent_reservations.joins(:pilates_class).where(pilates_classes: { instructor_id: @instructor.id }) if @instructor
    @recent_payments = Payment
      .includes(:user)
      .order(updated_at: :desc)
      .limit(15)
  end
end
