ActiveAdmin.register Credit do
  permit_params :user_id, :amount, :expires_at, :used

  menu priority: 5, label: "Créditos"

  scope :all, default: true
  scope :available
  scope :used
  scope :expired

  index do
    selectable_column
    id_column
    column "Usuario" do |credit|
      link_to credit.user.email, admin_user_path(credit.user)
    end
    column :amount
    column :expires_at do |credit|
      credit.expires_at.strftime("%d/%m/%Y")
    end
    column "Estado" do |credit|
      if credit.used?
        status_tag("Usado", class: "warning")
      elsif credit.expired?
        status_tag("Expirado", class: "error")
      else
        status_tag("Disponible", class: "ok")
      end
    end
    column :created_at
    actions
  end

  filter :user
  filter :amount
  filter :expires_at
  filter :used

  show do
    attributes_table do
      row "Usuario" do |credit|
        link_to credit.user.email, admin_user_path(credit.user)
      end
      row :amount
      row :expires_at
      row "Estado" do |credit|
        if credit.used?
          status_tag("Usado", class: "warning")
        elsif credit.expired?
          status_tag("Expirado", class: "error")
        else
          status_tag("Disponible", class: "ok")
        end
      end
      row :created_at
    end
  end

  form do |f|
    f.inputs "Información del Crédito" do
      f.input :user
      f.input :amount
      f.input :expires_at, as: :date_picker, hint: "Fecha de expiración del crédito (normalmente el último día del mes)"
      f.input :used, hint: "Marcar si el crédito ya fue usado"
    end
    f.actions
  end

  # Acción para crear créditos mensuales fácilmente
  action_item :create_monthly, only: :index do
    link_to "Crear Créditos Mensuales", new_admin_credit_path, class: "button"
  end

  batch_action :marcar_como_usados, confirm: "¿Marcar créditos como usados?" do |ids|
    Credit.where(id: ids).update_all(used: true)
    redirect_to collection_path, notice: "Créditos marcados como usados"
  end
end
