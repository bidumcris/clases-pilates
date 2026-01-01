class HomeController < ApplicationController
  # No requiere autenticación para la landing page
  def index
    redirect_to dashboard_path if user_signed_in?
  end

  def acceso
    redirect_to dashboard_path if user_signed_in?
  end
end
