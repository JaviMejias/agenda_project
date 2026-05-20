module Reservations
  class ConfirmService
    def self.call(reservation)
      limit_time = reservation.pending_status_set_at || reservation.updated_at
      return { status: :error, message: "Este enlace de confirmación ha expirado por seguridad (límite de 24 horas)." } if limit_time < 24.hours.ago
      return { status: :info, message: "Esta reserva ya se encuentra confirmada." } if reservation.confirmed?
      return { status: :error, message: "No se puede confirmar una reserva que ya ha sido cancelada." } if reservation.cancelled?

      Reservation.transaction do
        reservation.audit_author_name = "#{reservation.client_name} (Cliente Externo)"
        reservation.update!(status: :confirmed)
        Notification.create!(
          user: reservation.user,
          notifiable: reservation,
          message: "¡Reserva Confirmada! #{reservation.client_name} ha aceptado la reserva para #{reservation.property.name}."
        )
      end
      { status: :success, message: "¡Gracias! Tu reserva ha sido confirmada exitosamente." }
    end
  end
end
