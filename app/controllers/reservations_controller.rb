class ReservationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @reservations = current_user.reservations.includes(:pilates_class).order('pilates_classes.start_time ASC')
  end

  def create
    @pilates_class = PilatesClass.find(params[:pilates_class_id])
    
    # Verificar si tiene créditos disponibles
    available_credit = current_user.credits.available.first
    
    unless available_credit
      redirect_to creditos_path, alert: "No tienes créditos disponibles"
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
      available_credit.use!
      respond_to do |format|
        format.html { redirect_to agenda_path, notice: "Clase reservada exitosamente" }
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
