module Reservations
  class RejectService
    def self.call(reservation)
      limit_time = reservation.pending_status_set_at || reservation.updated_at
      return { status: :error, message: "Este enlace ha expirado por seguridad (límite de 24 horas)." } if limit_time < 24.hours.ago
      return { status: :info, message: "Esta reserva ya se encuentra cancelada." } if reservation.cancelled?

      Reservation.transaction do
        reservation.skip_notifications = true
        reservation.audit_author_name = "#{reservation.client_name} (Cliente Externo)"
        reservation.update!(status: :cancelled)
        Notification.create!(
          user: reservation.user,
          notifiable: reservation,
          message: "Reserva Rechazada: #{reservation.client_name} ha cancelado la solicitud para #{reservation.property.name}."
        )
      end
      { status: :success, message: "La reserva ha sido rechazada y cancelada." }
    end
  end
end
