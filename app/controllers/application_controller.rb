class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def authenticate_admin_user!
    authenticate_user!
    unless current_user&.admin?
      flash[:alert] = "No tienes acceso a esta sección"
      redirect_to root_path
    end
  end

  # Devise: redirección post-login por rol
  def after_sign_in_path_for(resource)
    return management_attendance_path if resource.respond_to?(:admin?) && resource.admin?
    return management_root_path if resource.respond_to?(:instructor?) && resource.instructor?

    super
  end
end
