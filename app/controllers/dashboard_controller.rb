class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @reservations = current_user.reservations.upcoming.limit(5)
    @credits = current_user.credits.available
    @requests = current_user.requests.pending_approval
  end

  def mi_actividad
    @user = current_user
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @reservations = current_user.reservations.by_month(@date)
  end
end
