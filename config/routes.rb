Rails.application.routes.draw do
  get "reports", to: "reports#index", as: :reports
  get "search", to: "search#global"
  resources :clients do
    collection do
      get :list
    end
  end
  devise_for :users
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

  root to: redirect("/users/sign_in")

  resources :public_reservations, only: [], param: :token, path: "r" do
    member do
      get :confirm
      get :reject
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
