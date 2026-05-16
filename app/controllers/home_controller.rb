class HomeController < ApplicationController
  def index
    if current_user.admin?
      redirect_to dashboard_path
    else
      redirect_to properties_path
    end
  end
end
