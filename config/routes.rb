Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Algunos navegadores piden /favicon.ico sí o sí (aunque definamos <link rel="icon">)
  # Redirigimos a un asset público estable.
  get "/favicon.ico", to: redirect("/icon.png")

  # Root path
  root "home#index"

  # Autenticación requerida para estas rutas
  authenticate :user do
    # Dashboard principal
    get "dashboard", to: "dashboard#index", as: :dashboard

    # Mi Actividad - Turnos del mes
    get "mi_actividad", to: "dashboard#mi_actividad", as: :mi_actividad

    # Ver Agenda (Calendario)
    get "agenda", to: "pilates_classes#index", as: :agenda
    get "agenda/:id", to: "pilates_classes#show", as: :clase

    # Reservas
    resources :reservations, only: [ :index, :create, :destroy ] do
      collection do
        post :reserve_class
        delete :cancel
      end
    end

    # Créditos
    get "creditos", to: "credits#index", as: :creditos

    # Solicitudes
    resources :requests, only: [ :index, :create ] do
      collection do
        post :create_alert
      end
    end

    # Panel de Gestión para Administradores e Instructores
    namespace :management do
      root "dashboard#index"
      get "dashboard", to: "dashboard#index", as: :dashboard

      # Caja (solo admin)
      get "cashbox", to: "cashbox#index", as: :cashbox
      post "cashbox/payments", to: "cashbox#create_payment", as: :cashbox_payments
      get "billing/debtors", to: "billing#debtors", as: :billing_debtors

      # Gestión de Créditos (solo admin)
      resources :credits, only: [ :index, :new, :create ] do
        collection do
          post :grant
          post :deduct
        end
      end

      # Gestión de Clases
      resources :classes, only: [ :index, :new, :create, :edit, :update, :destroy ] do
        collection do
          get :calendar
        end
        member do
          get :attendance
          patch :update_attendance
          post :mark_holiday
          post :unmark_holiday
        end
      end

      # Gestión de Alumnos
      resources :students, only: [ :index, :show, :edit, :update ] do
        member do
          post :add_credits
          patch :update_class_type
        end
      end

      # Gestión de Solicitudes
      resources :requests, only: [ :index, :show ] do
        member do
          post :approve
          post :reject
        end
      end
    end
  end

  # Páginas públicas
  get "home", to: "home#index"
  get "acceso", to: "home#acceso", as: :acceso

  post "contacto", to: "contacts#create", as: :contacto

  # Webhooks (sin auth)
  post "webhooks/mercado_pago", to: "webhooks/mercado_pago#receive", as: :webhooks_mercado_pago
end
