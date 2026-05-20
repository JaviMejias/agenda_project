require "test_helper"

class ReservationAuditTest < ActiveSupport::TestCase
  # ── Fixtures & helpers ────────────────────────────────────────────────
  def setup
    @reservation = reservations(:one)
    @user        = users(:one)
  end

  # ── Validaciones básicas del modelo ──────────────────────────────────

  test "es válido con atributos mínimos" do
    audit = ReservationAudit.new(
      reservation: @reservation,
      action: "creación"
    )
    assert audit.valid?
  end

  test "requiere una reserva" do
    audit = ReservationAudit.new(action: "creación")
    assert_not audit.valid?
    assert_includes audit.errors[:reservation], "debe existir"
  end

  test "requiere una acción" do
    audit = ReservationAudit.new(reservation: @reservation)
    assert_not audit.valid?
  end

  test "user_id es opcional (permite clientes externos)" do
    audit = ReservationAudit.new(
      reservation: @reservation,
      action: "payment_added",
      author_name: "Cliente Externo"
    )
    assert audit.valid?
  end

  # ── Relaciones ────────────────────────────────────────────────────────

  test "pertenece a una reserva" do
    audit = reservation_audits(:one)
    assert_equal reservations(:one), audit.reservation
  end

  test "pertenece opcionalmente a un usuario" do
    audit = reservation_audits(:one)
    assert_equal users(:one), audit.user
  end

  test "se destruye al destruir la reserva" do
    reservation = reservations(:two)
    # Crear un audit manualmente, sumado al que ya existe por el fixture 'two' = 2 audits
    reservation.reservation_audits.create!(action: "test_action")
    assert_difference "ReservationAudit.count", -2 do
      reservation.reservation_audits.destroy_all
    end
  end
end
