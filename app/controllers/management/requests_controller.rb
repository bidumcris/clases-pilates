class Management::RequestsController < Management::BaseController
  before_action :set_request, only: [ :show, :approve, :reject ]

  def index
    @requests = Request.includes(:user, :pilates_class).order(created_at: :desc)
    @requests = @requests.where(status: params[:status]) if params[:status].present?
    @pending_requests = @requests.where(status: :pending)
  end

  def show
  end

  def approve
    @request.approve!
      redirect_to management_requests_path, notice: "Solicitud aprobada exitosamente"
  end

  def reject
    @request.reject!
      redirect_to management_requests_path, notice: "Solicitud rechazada"
  end

  private

  def set_request
    @request = Request.find(params[:id])
  end
end
