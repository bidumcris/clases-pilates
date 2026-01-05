# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: "Dashboard - Clases Pilates" do
    columns do
      column do
        panel "Estadísticas Generales" do
          div do
            h3 "Usuarios: #{User.count}"
            h3 "Clases Activas: #{PilatesClass.upcoming.count}"
            h3 "Reservas Confirmadas: #{Reservation.where(status: :confirmed).count}"
            h3 "Créditos Disponibles: #{Credit.available.count}"
          end
        end

        panel "Reservas Recientes" do
          table_for Reservation.includes(:user, :pilates_class).order("created_at DESC").limit(10) do
            column "Usuario" do |reservation|
              reservation.user.email
            end
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
      end

      column do
        panel "Clases Próximas" do
          table_for PilatesClass.upcoming.order("start_time ASC").limit(10) do
            column "Nombre" do |pc|
              link_to pc.name, admin_pilates_class_path(pc)
            end
            column "Sala" do |pc|
              pc.room.name
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

        panel "Solicitudes Pendientes" do
          pending_requests = Request.where(status: :pending).count
          if pending_requests > 0
            div do
              h3 style: "color: #e74c3c;" do
                "#{pending_requests} solicitudes pendientes"
              end
              link_to "Ver todas", admin_requests_path(q: { status_eq: 0 }), class: "button"
            end
          else
            para "No hay solicitudes pendientes"
          end
        end

        panel "Acciones Rápidas" do
          div do
            link_to "Crear Nueva Clase", new_admin_pilates_class_path, class: "button"
            link_to "Asignar Créditos", new_admin_credit_path, class: "button"
            link_to "Ver Reportes", "#", class: "button"
          end
        end
      end
    end
  end
end
