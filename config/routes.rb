Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

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
    resources :reservations, only: [:index, :create, :destroy] do
      collection do
        post :reserve_class
        delete :cancel
      end
    end

    # Créditos
    get "creditos", to: "credits#index", as: :creditos

    # Solicitudes
    resources :requests, only: [:index, :create] do
      collection do
        post :create_alert
      end
    end
  end

  # Páginas públicas
  get "home", to: "home#index"
end
