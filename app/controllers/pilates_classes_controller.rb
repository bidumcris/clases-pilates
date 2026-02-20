class PilatesClassesController < ApplicationController
  before_action :authenticate_user!

  def index
    # Agenda semanal (recuperos): mostrar SOLO la semana actual.
    # Ignoramos el parámetro `date` para evitar navegación por mes/semanas futuras.
    @date = Date.current
    @week_start = @date.beginning_of_week(:monday)
    # Ocultar sábado y domingo: solo lunes a viernes
    @week_end = @week_start + 4.days
    range = @week_start.beginning_of_day..@week_end.end_of_day

    # Filtrar clases según nivel y tipo de usuario (sin filtrar por sala - mostrar todas)
    @classes = PilatesClass.upcoming.for_user(current_user)
    # Mostrar todas las clases de la semana
    @classes = @classes.where(start_time: range)

    # Agrupar por día y luego por hora
    @classes_by_day = @classes.group_by { |c| c.start_time.to_date }
  end

  def show
    @pilates_class = PilatesClass.find(params[:id])
    week_start = Date.current.beginning_of_week(:monday)
    week_end = week_start + 4.days
    allowed_range = week_start.beginning_of_day..week_end.end_of_day

    unless @pilates_class.start_time.in_time_zone.between?(allowed_range.begin, allowed_range.end)
      redirect_to agenda_path, alert: "Solo podés ver y reservar clases de la semana actual."
      return
    end

    if current_user.alumno? && @pilates_class.level != current_user.level
      redirect_to agenda_path, alert: "Esta clase no está disponible para tu nivel."
      return
    end
    @can_reserve_level = current_user.can_reserve_class?(@pilates_class)
    @reservable_now = @pilates_class.reservable_now?
    @can_reserve = @can_reserve_level && @reservable_now
    @has_reservation = current_user.reservations.where(pilates_class: @pilates_class, status: :confirmed).exists?
    @available_spots = @pilates_class.available_spots
  end
end
