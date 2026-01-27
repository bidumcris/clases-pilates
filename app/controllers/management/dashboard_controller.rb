class Management::DashboardController < Management::BaseController
  def index
    # Conteos para dashboard de administradoras
    @students_active_count = User.where(role: :alumno, active: true).count

    today_range = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day
    classes_scope = PilatesClass.all
    if current_user.instructor?
      instructor = current_user.instructor_profile
      classes_scope = instructor ? classes_scope.where(instructor_id: instructor.id) : classes_scope.none
    end

    @classes_today_count = classes_scope.where(start_time: today_range).count
    @pending_requests_count = Request.pending_approval.count
    @classes_count = classes_scope.upcoming.count
  end
end
