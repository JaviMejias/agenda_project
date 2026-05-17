class Public::MyReservationsController < ApplicationController
  before_action :authenticate_user!
  layout "public"

  def index
    unless current_user.client?
      redirect_to dashboard_path, alert: "Esta sección es exclusiva para clientes."
      return
    end

    # Buscar todas las reservas que correspondan al email del cliente logeado
    # Esto une el historial de reservas que hicieron como invitados con su cuenta registrada
    @clients = Client.where(email: current_user.email)
    @reservations = Reservation.includes(:property, :payments).where(client: @clients).order(start_time: :desc)
  end
end
