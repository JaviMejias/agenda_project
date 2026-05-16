class ApplicationController < ActionController::Base
  include Pagy::Method
  include Pundit::Authorization

  before_action :authenticate_user!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  around_action :set_time_zone

  private

  def user_not_authorized
    flash[:alert] = "No tienes permiso para realizar esta acción."
    redirect_to(request.referrer || root_path)
  end

  def set_time_zone(&block)
    Time.use_zone("Santiago", &block)
  end
end
