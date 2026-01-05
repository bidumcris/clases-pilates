ActiveAdmin.register Reservation do
  permit_params :user_id, :pilates_class_id, :status, :reserved_at

  menu priority: 4, label: "Reservas"

  scope :all, default: true
  scope :confirmed
  scope :pending
  scope :cancelled
  scope :completed

  index do
    selectable_column
    id_column
    column "Usuario" do |reservation|
      link_to reservation.user.email, admin_user_path(reservation.user)
    end
    column "Clase" do |reservation|
      link_to reservation.pilates_class.name, admin_pilates_class_path(reservation.pilates_class)
    end
    column "Fecha Clase" do |reservation|
      reservation.pilates_class.start_time.strftime("%d/%m/%Y %H:%M")
    end
    column :status do |reservation|
      status_tag reservation.status
    end
    column "Reservado" do |reservation|
      reservation.reserved_at.strftime("%d/%m/%Y %H:%M")
    end
    column :created_at
    actions
  end

  filter :user
  filter :pilates_class
  filter :status
  filter :reserved_at
  filter :created_at

  show do
    attributes_table do
      row "Usuario" do |reservation|
        link_to reservation.user.email, admin_user_path(reservation.user)
      end
      row "Clase" do |reservation|
        link_to reservation.pilates_class.name, admin_pilates_class_path(reservation.pilates_class)
      end
      row "Fecha de la Clase" do |reservation|
        reservation.pilates_class.start_time.strftime("%d/%m/%Y %H:%M")
      end
      row "Sala" do |reservation|
        reservation.pilates_class.room.name
      end
      row "Instructor" do |reservation|
        reservation.pilates_class.instructor.name
      end
      row :status do |reservation|
        status_tag reservation.status
      end
      row :reserved_at
      row :created_at
    end
  end

  form do |f|
    f.inputs "Información de la Reserva" do
      f.input :user
      f.input :pilates_class
      f.input :status, as: :select, collection: Reservation.statuses.keys.map { |k| [ k.humanize, k ] }
      f.input :reserved_at, as: :datetime_picker
    end
    f.actions
  end

  batch_action :cancelar, confirm: "¿Estás seguro de cancelar las reservas seleccionadas?" do |ids|
    Reservation.where(id: ids).update_all(status: :cancelled)
    redirect_to collection_path, notice: "Reservas canceladas exitosamente"
  end
end
