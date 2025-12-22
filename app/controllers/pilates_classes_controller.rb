class PilatesClassesController < ApplicationController
  before_action :authenticate_user!

  def index
    @room_filter = params[:room_id]
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    
    @rooms = Room.all
    @classes = PilatesClass.upcoming
    @classes = @classes.by_room(@room_filter) if @room_filter.present?
    @classes = @classes.where('DATE(start_time) = ?', @date)
    
    # Agrupar por hora para mostrar en el calendario
    @classes_by_hour = @classes.group_by { |c| c.start_time.hour }
  end

  def show
    @pilates_class = PilatesClass.find(params[:id])
    @can_reserve = current_user.can_reserve_class?(@pilates_class)
    @has_reservation = current_user.reservations.where(pilates_class: @pilates_class, status: :confirmed).exists?
    @available_spots = @pilates_class.available_spots
  end
end
