class Management::DashboardController < Management::BaseController
  def index
    upcoming = PilatesClass.upcoming.order(start_time: :asc)
    if current_user.instructor?
      instructor = current_user.instructor_profile
      upcoming = instructor ? upcoming.where(instructor_id: instructor.id) : upcoming.none
    end
    @upcoming_classes = upcoming.limit(10)

    @pending_requests = Request.pending_approval.limit(10)
    reservations = Reservation.confirmed.includes(:user, :pilates_class).order(created_at: :desc)
    if current_user.instructor?
      instructor = current_user.instructor_profile
      reservations = instructor ? reservations.joins(:pilates_class).where(pilates_classes: { instructor_id: instructor.id }) : reservations.none
    end
    @recent_reservations = reservations.limit(10)
    @total_students = User.where(role: :alumno).count
    @active_classes_today = PilatesClass.where("DATE(start_time) = ?", Date.current).count
  end
end
