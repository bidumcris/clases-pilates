class ReservationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @reservations = current_user.reservations.includes(:pilates_class).order("pilates_classes.start_time ASC")
  end

  def create
    @pilates_class = PilatesClass.find(params[:pilates_class_id])

    week_start = Date.current.beginning_of_week(:monday)
    # Agenda semanal (recuperos): solo lunes a viernes
    week_end = week_start + 4.days
    allowed_range = week_start.beginning_of_day..week_end.end_of_day

    unless @pilates_class.start_time.in_time_zone.between?(allowed_range.begin, allowed_range.end)
      redirect_to agenda_path, alert: "Solo podés reservar clases de la semana actual."
      return
    end

    # Verificar si tiene créditos disponibles
    available_credit = current_user.credits.available_this_month.first

    unless available_credit
      redirect_to creditos_path, alert: "No tienes recuperos disponibles"
      return
    end

    # Verificar si puede reservar esta clase
    unless current_user.can_reserve_class?(@pilates_class)
      redirect_to agenda_path, alert: "No tienes el nivel necesario para esta clase"
      return
    end

    # Verificar disponibilidad
    if @pilates_class.full?
      redirect_to agenda_path, alert: "La clase está completa"
      return
    end

    @reservation = current_user.reservations.build(
      pilates_class: @pilates_class,
      status: :confirmed,
      reserved_at: Time.current
    )

    if @reservation.save
      # Usar 1 crédito
      available_credit.use!(1)
      respond_to do |format|
        format.html { redirect_to agenda_path, notice: "Clase reservada exitosamente. Se utilizó 1 recupero." }
        format.turbo_stream
      end
    else
      redirect_to agenda_path, alert: @reservation.errors.full_messages.join(", ")
    end
  end

  def destroy
    @reservation = current_user.reservations.find(params[:id])
    @pilates_class = @reservation.pilates_class

    if @reservation.update(status: :cancelled)
      respond_to do |format|
        format.html { redirect_to mi_actividad_path, notice: "Reserva cancelada" }
        format.turbo_stream
      end
    else
      redirect_to mi_actividad_path, alert: "Error al cancelar la reserva"
    end
  end
end
