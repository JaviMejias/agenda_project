class PublicReservationsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  layout "public"

  before_action :set_reservation

  def confirm
    result = @reservation.confirm_by_client!
    @message = result[:message]
    @status = result[:status]
  end

  def reject
    result = @reservation.reject_by_client!
    @message = result[:message]
    @status = result[:status]
  end

  private

  def set_reservation
    @reservation = Reservation.find_by!(token: params[:token])
  rescue ActiveRecord::RecordNotFound
    render plain: "Reserva no encontrada", status: :not_found
  end
end
