class Management::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin_or_instructor

  private

  def ensure_admin_or_instructor
    unless current_user.admin? || current_user.instructor?
      flash[:alert] = "No tienes acceso a esta sección"
      redirect_to dashboard_path
    end
  end

  def ensure_admin!
    return if current_user.admin?

    flash[:alert] = "Solo administradores pueden realizar esta acción"
    redirect_to management_root_path
  end
end
