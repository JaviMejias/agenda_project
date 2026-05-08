class PublicReservationsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  layout "public"

  before_action :set_reservation

  def confirm
    if @reservation.created_at < 24.hours.ago
      @message = "Este enlace de confirmación ha expirado por seguridad (límite de 24 horas)."
      @status = :error
    elsif @reservation.confirmed?
      @message = "Esta reserva ya se encuentra confirmada."
      @status = :info
    elsif @reservation.cancelled?
      @message = "No se puede confirmar una reserva que ya ha sido cancelada."
      @status = :error
    else
      @reservation.skip_notifications = true
      @reservation.update!(status: :confirmed)
      Notification.create!(
        user: @reservation.user,
        notifiable: @reservation,
        message: "¡Reserva Confirmada! #{@reservation.client_name} ha aceptado la reserva para #{@reservation.property.name}."
      )
      @message = "¡Gracias! Tu reserva ha sido confirmada exitosamente."
      @status = :success
    end
  end

  def reject
    if @reservation.created_at < 24.hours.ago
      @message = "Este enlace ha expirado por seguridad (límite de 24 horas)."
      @status = :error
    elsif @reservation.cancelled?
      @message = "Esta reserva ya se encuentra cancelada."
      @status = :info
    else
      @reservation.skip_notifications = true
      @reservation.update!(status: :cancelled)
      Notification.create!(
        user: @reservation.user,
        notifiable: @reservation,
        message: "Reserva Rechazada: #{@reservation.client_name} ha cancelado la solicitud para #{@reservation.property.name}."
      )
      @message = "La reserva ha sido rechazada y cancelada."
      @status = :success
    end
  end

  private

  def set_reservation
    @reservation = Reservation.find_by!(token: params[:token])
  rescue ActiveRecord::RecordNotFound
    render plain: "Reserva no encontrada", status: :not_found
  end
end
