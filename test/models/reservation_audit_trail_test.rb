require "test_helper"

# Tests para el audit automático generado desde el modelo Reservation.
# Cubre: creación, actualización de campos relevantes, y cambios de estado.
class ReservationAuditTrailTest < ActiveSupport::TestCase
  def setup
    @user     = users(:one)
    @property = properties(:one)
    Current.user = @user
  end

  def teardown
    Current.user = nil
  end

  # ── Creación ──────────────────────────────────────────────────────────

  test "crear una reserva genera un audit con acción creación" do
    reservation = nil
    assert_difference "ReservationAudit.count", 1 do
      reservation = Reservation.create!(
        property: @property,
        user: @user,
        client_name: "Test Cliente",
        start_time: 5.days.from_now.change(hour: 10),
        end_time:   6.days.from_now.change(hour: 10),
        status: :pending,
        skip_notifications: true
      )
    end
    audit = reservation.reservation_audits.last
    assert_equal "creación", audit.action
    assert_equal @user.id, audit.user_id
  end

  # ── Actualización ────────────────────────────────────────────────────

  test "actualizar start_time genera un audit con acción actualización" do
    reservation = reservations(:two) # status: pending
    assert_difference "reservation.reservation_audits.count", 1 do
      reservation.update!(
        start_time: 8.days.from_now.change(hour: 10),
        end_time:   9.days.from_now.change(hour: 10),
        skip_notifications: true
      )
    end
    audit = reservation.reservation_audits.last
    assert_equal "actualización", audit.action
  end

  # ── Cambio de estado ─────────────────────────────────────────────────

  test "confirmar una reserva genera un audit con acción confirmed" do
    reservation = reservations(:two) # status: pending
    assert_difference "reservation.reservation_audits.count", 1 do
      reservation.update!(status: :confirmed, skip_notifications: true)
    end
    audit = reservation.reservation_audits.last
    assert_equal "confirmed", audit.action
  end

  test "cancelar una reserva genera un audit con acción cancelled" do
    reservation = reservations(:one) # status: confirmed
    assert_difference "reservation.reservation_audits.count", 1 do
      reservation.update!(status: :cancelled, skip_notifications: true)
    end
    audit = reservation.reservation_audits.last
    assert_equal "cancelled", audit.action
  end

  # ── Solo admins ──────────────────────────────────────────────────────

  test "los audits creados sin usuario logueado usan author_name como Sistema / Externo" do
    Current.user = nil
    reservation  = reservations(:two)
    reservation.update!(status: :confirmed, skip_notifications: true)
    audit = reservation.reservation_audits.last
    assert_nil audit.user_id
    assert_equal "Sistema / Externo", audit.author_name
  end
end
