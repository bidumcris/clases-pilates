ActiveAdmin.register Request do
  permit_params :user_id, :pilates_class_id, :request_type, :status

  menu priority: 6, label: "Solicitudes"

  scope :all, default: true
  scope :pending
  scope :approved
  scope :rejected
  scope :alerts

  index do
    selectable_column
    id_column
    column "Usuario" do |request|
      link_to request.user.email, admin_user_path(request.user)
    end
    column "Clase" do |request|
      link_to request.pilates_class.name, admin_pilates_class_path(request.pilates_class)
    end
    column "Tipo" do |request|
      request.request_type == 'alert' ? "Alerta" : "Turno Fijo"
    end
    column :status do |request|
      status_tag request.status
    end
    column :created_at
    actions
  end

  filter :user
  filter :pilates_class
  filter :request_type
  filter :status
  filter :created_at

  show do
    attributes_table do
      row "Usuario" do |request|
        link_to request.user.email, admin_user_path(request.user)
      end
      row "Clase" do |request|
        link_to request.pilates_class.name, admin_pilates_class_path(request.pilates_class)
      end
      row "Tipo" do |request|
        request.request_type == 'alert' ? "Alerta de Cupo" : "Turno Fijo"
      end
      row :status do |request|
        status_tag request.status
      end
      row :created_at
    end
  end

  form do |f|
    f.inputs "Información de la Solicitud" do
      f.input :user
      f.input :pilates_class
      f.input :request_type, as: :select, collection: [['Alerta', 'alert'], ['Turno Fijo', 'fixed_slot']]
      f.input :status, as: :select, collection: Request.statuses.keys.map { |k| [k.humanize, k] }
    end
    f.actions
  end

  member_action :approve, method: :post do
    resource.approve!
    redirect_to resource_path, notice: "Solicitud aprobada"
  end

  member_action :reject, method: :post do
    resource.reject!
    redirect_to resource_path, notice: "Solicitud rechazada"
  end

  action_item :approve, only: :show, if: proc { request.pending? } do
    link_to "Aprobar", approve_admin_request_path(request), method: :post
  end

  action_item :reject, only: :show, if: proc { request.pending? } do
    link_to "Rechazar", reject_admin_request_path(request), method: :post
  end

  batch_action :aprobar, confirm: "¿Aprobar solicitudes seleccionadas?" do |ids|
    Request.where(id: ids).find_each(&:approve!)
    redirect_to collection_path, notice: "Solicitudes aprobadas"
  end

  batch_action :rechazar, confirm: "¿Rechazar solicitudes seleccionadas?" do |ids|
    Request.where(id: ids).find_each(&:reject!)
    redirect_to collection_path, notice: "Solicitudes rechazadas"
  end
end

