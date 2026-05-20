class ApplicationController < ActionController::Base
  include Pagy::Method
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :set_current_user
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :ensure_non_client_for_admin_area
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  around_action :set_time_zone

  layout :layout_by_resource

  private

  def set_current_user
    Current.user = current_user if defined?(current_user)
  end

  def ensure_non_client_for_admin_area
    return unless user_signed_in? && current_user.client?

    allowed_controllers = [
      "public/properties",
      "public/reservations",
      "public/my_reservations",
      "home",
      "pwa"
    ]

    is_allowed = allowed_controllers.any? { |c| params[:controller].start_with?(c) } ||
                 devise_controller?

    unless is_allowed
      flash[:alert] = "Acceso denegado: esta es un área exclusiva para administradores y operadores."
      redirect_to my_reservations_path
    end
  end

  def layout_by_resource
    devise_controller? ? "public" : "application"
  end

  def user_not_authorized
    flash[:alert] = "No tienes permiso para realizar esta acción."
    redirect_to(request.referrer || root_path)
  end

  def set_time_zone(&block)
    Time.use_zone("Santiago", &block)
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      dashboard_path
    elsif resource.client?
      my_reservations_path
    else
      properties_path
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name ])
  end
end
