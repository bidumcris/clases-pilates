class PilatesClassesController < ApplicationController
  before_action :authenticate_user!

  def index
    # Calendario semanal - obtener inicio de semana
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @week_start = @date.beginning_of_week(:monday)
    @week_end = @week_start + 6.days

    # Filtrar clases según nivel y tipo de usuario (sin filtrar por sala - mostrar todas)
    @classes = PilatesClass.upcoming.for_user(current_user)
    # Mostrar todas las clases de la semana
    @classes = @classes.where("DATE(start_time) >= ? AND DATE(start_time) <= ?", @week_start, @week_end)

    # Agrupar por día y luego por hora
    @classes_by_day = @classes.group_by { |c| c.start_time.to_date }
  end

  def show
    @pilates_class = PilatesClass.find(params[:id])
    @can_reserve = current_user.can_reserve_class?(@pilates_class)
    @has_reservation = current_user.reservations.where(pilates_class: @pilates_class, status: :confirmed).exists?
    @available_spots = @pilates_class.available_spots
  end
end
