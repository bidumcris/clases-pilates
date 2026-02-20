class Management::CompanyController < Management::BaseController
  before_action :ensure_admin!, only: [ :show, :update ]

  def show
    @accion_minprevturno = Setting.get("accion_minprevturno").presence || "0"
  end

  def update
    if params.dig(:company, :accion_minprevturno).present?
      Setting.set("accion_minprevturno", params[:company][:accion_minprevturno])
    end
    # TODO: persistir el resto de params cuando exista modelo
    redirect_to management_company_path, notice: "Configuración guardada correctamente."
  end
end
