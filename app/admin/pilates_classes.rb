ActiveAdmin.register PilatesClass do
  permit_params :name, :level, :class_type, :room_id, :instructor_id, :start_time, :end_time, :max_capacity, :class_type

  menu priority: 2, label: "Clases"

  scope :all, default: true
  scope :upcoming
  scope :past

  index do
    selectable_column
    id_column
    column :name
    column :level do |pc|
      status_tag pc.level
    end
    column "Tipo" do |pc|
      status_tag pc.class_type, class: pc.privada? ? "warning" : "ok"
    end
    column :room
    column :instructor
    column "Fecha/Hora" do |pc|
      pc.start_time.strftime("%d/%m/%Y %H:%M")
    end
    column "Disponibilidad" do |pc|
      "#{pc.available_spots}/#{pc.max_capacity}"
    end
    column "Ocupación" do |pc|
      percentage = pc.availability_percentage
      tag_class =
        if percentage < 25
          "error"
        elsif percentage < 50
          "warning"
        else
          "ok"
        end

      status_tag("#{100 - percentage}%", class: tag_class)
    end
    column :created_at
    actions
  end

  filter :name
  filter :level
  filter :class_type
  filter :room
  filter :instructor
  filter :start_time
  filter :created_at

  show do
    attributes_table do
      row :name
      row :level do |pc|
        status_tag pc.level
      end
      row "Tipo de Clase" do |pc|
        status_tag pc.class_type, class: pc.privada? ? "warning" : "ok"
      end
      row :room
      row :instructor
      row :start_time
      row :end_time
      row :max_capacity
      row "Disponibles" do |pc|
        pc.available_spots
      end
      row "Ocupación" do |pc|
        "#{100 - pc.availability_percentage}%"
      end
      row :created_at
      row :updated_at
    end

    panel "Reservas" do
      table_for pilates_class.reservations.includes(:user) do
        column "Usuario" do |reservation|
          reservation.user.email
        end
        column "Estado" do |reservation|
          status_tag reservation.status
        end
        column "Reservado" do |reservation|
          reservation.reserved_at.strftime("%d/%m/%Y %H:%M")
        end
        column "Acciones" do |reservation|
          link_to "Ver", admin_reservation_path(reservation)
        end
      end
    end
  end

  form do |f|
    f.inputs "Información de la Clase" do
      f.input :name
      f.input :level, as: :select, collection: PilatesClass.levels.keys.map { |k| [ k.humanize, k ] }
      f.input :class_type, as: :select, collection: PilatesClass.class_types.keys.map { |k| [ k.humanize, k ] }, hint: "Grupal: clases normales. Privada: para un solo alumno (1 alumno, 1 sala)"
      f.input :room
      f.input :instructor
      f.input :start_time, as: :datetime_picker
      f.input :end_time, as: :datetime_picker
      f.input :max_capacity
    end
    f.actions
  end

  action_item :duplicate, only: :show do
    link_to "Duplicar Clase", duplicate_admin_pilates_class_path(pilates_class), method: :post
  end

  member_action :duplicate, method: :post do
    new_class = resource.dup
    new_class.start_time = resource.start_time + 7.days
    new_class.end_time = resource.end_time + 7.days
    new_class.save
    redirect_to admin_pilates_class_path(new_class), notice: "Clase duplicada exitosamente"
  end
end
