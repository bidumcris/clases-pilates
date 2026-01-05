ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :level, :class_type

  menu priority: 3, label: "Usuarios"

  scope :all, default: true
  scope :inicial
  scope :basic
  scope :intermediate
  scope :advanced

  index do
    selectable_column
    id_column
    column :email
    column :level do |user|
      status_tag user.level
    end
    column "Tipo de Clase" do |user|
      status_tag user.class_type, class: user.privada? ? "warning" : "ok"
    end
    column "Reservas" do |user|
      user.reservations.where(status: :confirmed).count
    end
    column "Créditos Disponibles" do |user|
      user.credits.available.count
    end
    column :created_at
    actions
  end

  filter :email
  filter :level
  filter :class_type
  filter :created_at

  show do
    attributes_table do
      row :email
      row :level do |user|
        status_tag user.level
      end
      row "Tipo de Clase" do |user|
        status_tag user.class_type, class: user.privada? ? "warning" : "ok"
      end
      row :created_at
      row :updated_at
    end

    panel "Reservas" do
      table_for user.reservations.includes(:pilates_class).order("created_at DESC").limit(10) do
        column "Clase" do |reservation|
          reservation.pilates_class.name
        end
        column "Fecha" do |reservation|
          reservation.pilates_class.start_time.strftime("%d/%m/%Y %H:%M")
        end
        column "Estado" do |reservation|
          status_tag reservation.status
        end
        column "Acciones" do |reservation|
          link_to "Ver", admin_reservation_path(reservation)
        end
      end
    end

    panel "Créditos" do
      table_for user.credits.order("expires_at DESC") do
        column "Cantidad" do |credit|
          credit.amount
        end
        column "Expira" do |credit|
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
      end
    end
  end

  form do |f|
    f.inputs "Información del Usuario" do
      f.input :email
      f.input :password, hint: "Dejar en blanco si no quieres cambiarlo"
      f.input :password_confirmation
      f.input :level, as: :select, collection: User.levels.keys.map { |k| [ k.humanize, k ] }, hint: "Nivel del alumno (inicial, básico, intermedio, avanzado)"
      f.input :class_type, as: :select, collection: User.class_types.keys.map { |k| [ k.humanize, k ] }, hint: "Grupal: clases normales. Privada: para alumnos con patología o lesión"
    end
    f.actions
  end

  action_item :add_credits, only: :show do
    link_to "Agregar Créditos", new_admin_credit_path(credit: { user_id: user.id })
  end
end
