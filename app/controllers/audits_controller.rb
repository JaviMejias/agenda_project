class AuditsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Scope audits according to the user role and properties (IDOR protection)
    base_scope = ReservationAudit.includes(:user, reservation: :property)
    @properties = Property.all

    if params[:property_id].present?
      base_scope = base_scope.where(reservations: { property_id: params[:property_id] })
    end

    if params[:action_type].present?
      base_scope = base_scope.where(action: params[:action_type])
    end

    @pagy, @audits = pagy(base_scope.order(created_at: :desc), limit: 15)
  end
end
