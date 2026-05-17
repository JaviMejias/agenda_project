class HomeController < ApplicationController
  def index
    if current_user.admin?
      redirect_to dashboard_path
    elsif current_user.client?
      redirect_to my_reservations_path
    else
      redirect_to properties_path
    end
  end
end
