Rails.application.routes.draw do
  devise_for :users
  
  root to: redirect("/users/sign_in")
  
  get "up" => "rails/health#show", as: :rails_health_check
end