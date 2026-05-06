Rails.application.routes.draw do
  get "reports", to: "reports#index", as: :reports
  resources :clients do
    collection do
      get :list
    end
  end
  devise_for :users
  resources :users
  resources :companies do
    post :associate_properties, on: :member
  end

  resources :properties do
    get :list, on: :collection
    resources :reservations, only: [ :new, :create ]
    member do
      get :gallery
      delete "images/:image_id", to: "properties#destroy_image", as: :image
    end
  end
  resources :reservations, except: [ :new, :create ] do
    collection do
      get :list
      get :calendar_list
    end
  end

  get "dashboard", to: "dashboard#index", as: :dashboard

  authenticated :user, ->(u) { u.admin? } do
    root "dashboard#index", as: :admin_root
  end

  authenticated :user, ->(u) { u.normal? } do
    root "properties#index", as: :user_root
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
