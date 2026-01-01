class Management::DashboardController < Management::BaseController
  def index
    @upcoming_classes = PilatesClass.upcoming.limit(10).order(start_time: :asc)
    @pending_requests = Request.pending_approval.limit(10)
    @recent_reservations = Reservation.confirmed.includes(:user, :pilates_class).order(created_at: :desc).limit(10)
    @total_students = User.where.not(level: :admin).count
    @active_classes_today = PilatesClass.where("DATE(start_time) = ?", Date.current).count
  end
end
