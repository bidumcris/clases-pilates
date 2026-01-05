ActiveAdmin.register Room do
  permit_params :name, :room_type, :capacity

  menu priority: 7, label: "Salas"

  index do
    selectable_column
    id_column
    column :name
    column :room_type do |room|
      status_tag room.room_type.humanize
    end
    column :capacity
    column "Clases Programadas" do |room|
      room.pilates_classes.upcoming.count
    end
    column :created_at
    actions
  end

  filter :name
  filter :room_type
  filter :capacity

  show do
    attributes_table do
      row :name
      row :room_type do |room|
        status_tag room.room_type.humanize
      end
      row :capacity
      row :created_at
    end

    panel "Clases Programadas" do
      table_for room.pilates_classes.upcoming.order("start_time ASC").limit(10) do
        column "Nombre" do |pc|
          link_to pc.name, admin_pilates_class_path(pc)
        end
        column "Instructor" do |pc|
          pc.instructor.name
        end
        column "Fecha/Hora" do |pc|
          pc.start_time.strftime("%d/%m/%Y %H:%M")
        end
        column "Disponibilidad" do |pc|
          "#{pc.available_spots}/#{pc.max_capacity}"
        end
      end
    end
  end

  form do |f|
    f.inputs "Información de la Sala" do
      f.input :name
      f.input :room_type, as: :select, collection: Room.room_types.keys.map { |k| [ k.humanize, k ] }
      f.input :capacity
    end
    f.actions
  end
end
