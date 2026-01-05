class RequestsController < ApplicationController
  before_action :authenticate_user!

  def index
    @requests = current_user.requests.includes(:pilates_class).order(created_at: :desc)
    @alerts = @requests.alerts.pending
    @fixed_slots = @requests.pending_approval
  end

  def create
    @pilates_class = PilatesClass.find(params[:pilates_class_id])
    request_type = params[:request_type] || "alert"

    @request = current_user.requests.build(
      pilates_class: @pilates_class,
      request_type: request_type,
      status: :pending
    )

    if @request.save
      respond_to do |format|
        format.html { redirect_to requests_path, notice: "Solicitud creada exitosamente" }
        format.turbo_stream
      end
    else
      redirect_to agenda_path, alert: @request.errors.full_messages.join(", ")
    end
  end

  def create_alert
    create
  end
end
