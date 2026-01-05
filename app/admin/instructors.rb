ActiveAdmin.register Instructor do
  permit_params :name, :email, :phone

  menu priority: 8, label: "Instructores"

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :phone
    column "Clases Programadas" do |instructor|
      instructor.pilates_classes.upcoming.count
    end
    column :created_at
    actions
  end

  filter :name
  filter :email
  filter :created_at

  show do
    attributes_table do
      row :name
      row :email
      row :phone
      row :created_at
    end

    panel "Clases Programadas" do
      table_for instructor.pilates_classes.upcoming.order("start_time ASC").limit(10) do
        column "Nombre" do |pc|
          link_to pc.name, admin_pilates_class_path(pc)
        end
        column "Sala" do |pc|
          pc.room.name
        end
        column "Fecha/Hora" do |pc|
          pc.start_time.strftime("%d/%m/%Y %H:%M")
        end
        column "Nivel" do |pc|
          status_tag pc.level
        end
      end
    end
  end

  form do |f|
    f.inputs "Información del Instructor" do
      f.input :name
      f.input :email
      f.input :phone
    end
    f.actions
  end
end
