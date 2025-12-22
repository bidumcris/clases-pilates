class CreditsController < ApplicationController
  before_action :authenticate_user!

  def index
    @credits = current_user.credits.order(expires_at: :asc)
    @available_credits = @credits.available
    @expired_credits = @credits.expired
    @used_credits = @credits.where(used: true)
    
    # Créditos por mes de expiración
    @credits_by_month = @available_credits.group_by { |c| c.expires_at.beginning_of_month }
  end
end
