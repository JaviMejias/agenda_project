Rails.application.routes.draw do
  get "reports", to: "reports#index", as: :reports
  get "search", to: "search#global"
  resources :clients do
    collection do
      get :list
    end
  end
  devise_for :users, path_names: { registration: "registrarse" }, controllers: {
    registrations: "users/registrations"
  }
  resources :users
  resources :companies do
    member do
      post :associate_properties
      delete :destroy_logo
    end
  end

  resources :properties do
    get :list, on: :collection
    resources :reservations, only: [ :new, :create ]
    resources :expenses
    member do
      get :gallery
      delete "images/:image_id", to: "properties#destroy_image", as: :image
    end
  end
  resources :reservations, except: [ :new, :create ] do
    resources :payments, except: [ :index, :show ]
    member do
      get :receipt
    end
    collection do
      get :list
      get :calendar_list
    end
  end

  resources :notifications, only: [ :index, :update, :destroy ] do
    collection do
      post :mark_all_as_read
    end
  end

  get "dashboard", to: "dashboard#index", as: :dashboard

  authenticated :user do
    root "home#index", as: :authenticated_root
  end

  root "public/properties#index"

  scope module: :public do
    resources :properties, only: [ :index, :show ], path: "p", as: :public_property do
      member do
        get :booking
        get :events
      end
      resources :reservations, only: [ :create ], as: :public_reservations
    end
    resources :reservations, only: [ :show ], param: :token, path: "r", as: :public_reservation do
      member do
        get :confirm
        get :reject
        get :receipt
        post :add_payment
        delete "delete_payment/:payment_id", to: "reservations#delete_payment", as: :delete_payment
        post "upload_voucher/:payment_id", to: "reservations#upload_voucher", as: :upload_voucher
      end
    end
    resources :my_reservations, only: [ :index ], path: "mis-reservas"
  end

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
