class Users::RegistrationsController < Devise::RegistrationsController
  layout "public"

  def build_resource(hash = {})
    super
    self.resource.role = :client if self.resource.new_record?
  end

  protected

  def after_sign_up_path_for(resource)
    # Redirigir al cliente a la vitrina o a sus reservas
    root_path
  end
end
