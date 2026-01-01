class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin_or_instructor

  private

  def ensure_admin_or_instructor
    unless current_user.admin? || current_user.instructor?
      flash[:alert] = "No tienes acceso a esta sección"
      redirect_to dashboard_path
    end
  end
end
