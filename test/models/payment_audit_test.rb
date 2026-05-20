require "test_helper"

# Tests para el comportamiento de auditoría automática en el modelo Payment.
# Cubre: creación, actualización real, actualización sin cambios, y eliminación.
class PaymentAuditTest < ActiveSupport::TestCase
  def setup
    @reservation = reservations(:one)
    @user        = users(:one)
    Current.user = @user
  end

  def teardown
    Current.user = nil
  end

  # ── Creación ──────────────────────────────────────────────────────────

  test "crear un pago genera un audit con acción payment_added" do
    assert_difference "@reservation.reservation_audits.count", 1 do
      @reservation.payments.create!(
        amount: 50_000,
        payment_date: Time.current,
        payment_method: "transfer",
        transaction_type: "abono"
      )
    end
    audit = @reservation.reservation_audits.last
    assert_equal "payment_added", audit.action
  end

  test "el audit de creación registra el usuario actual" do
    @reservation.payments.create!(
      amount: 50_000,
      payment_date: Time.current,
      payment_method: "transfer",
      transaction_type: "abono"
    )
    audit = @reservation.reservation_audits.last
    assert_equal @user.id, audit.user_id
  end

  # ── Actualización con cambios ─────────────────────────────────────────

  test "actualizar el monto genera un audit con acción payment_updated" do
    payment = @reservation.payments.create!(
      amount: 50_000,
      payment_date: Time.current,
      payment_method: "transfer",
      transaction_type: "abono",
      status: :pending
    )
    assert_difference "@reservation.reservation_audits.count", 1 do
      payment.update!(amount: 99_999)
    end
    audit = @reservation.reservation_audits.last
    assert_equal "payment_updated", audit.action
  end

  test "el audit de actualización incluye los valores anteriores y nuevos" do
    payment = @reservation.payments.create!(
      amount: 50_000,
      payment_date: Time.current,
      payment_method: "transfer",
      transaction_type: "abono",
      status: :pending
    )
    monto_anterior = payment.amount
    payment.update!(amount: 75_000)

    audit = @reservation.reservation_audits.last
    assert_equal "payment_updated", audit.action
    # El detalle del cambio de amount tiene la forma [antes, despues]
    assert_equal [ monto_anterior.to_s, "75000.0" ], audit.details["amount"].map(&:to_s)
  end

  # ── Actualización SIN cambios (el bug corregido) ──────────────────────

  test "actualizar un pago sin cambiar nada NO genera un nuevo audit" do
    payment = @reservation.payments.create!(
      amount: 50_000,
      payment_date: Time.current,
      payment_method: "transfer",
      transaction_type: "abono",
      status: :pending
    )
    count_antes = @reservation.reservation_audits.count
    # Guardamos con los mismos valores
    payment.update!(
      amount: payment.amount,
      payment_method: payment.payment_method,
      transaction_type: payment.transaction_type,
      payment_date: payment.payment_date
    )
    assert_equal count_antes, @reservation.reservation_audits.count
  end

  # ── Aprobación / Rechazo ──────────────────────────────────────────────

  test "aprobar un pago genera un audit con acción payment_approved" do
    payment = @reservation.payments.create!(
      amount: 20_000,
      payment_date: Time.current,
      payment_method: "transfer",
      transaction_type: "abono"
    )
    assert_difference "@reservation.reservation_audits.count", 1 do
      payment.update!(status: :approved)
    end
    audit = @reservation.reservation_audits.last
    assert_equal "payment_approved", audit.action
  end

  test "rechazar un pago genera un audit con acción payment_rejected" do
    payment = @reservation.payments.create!(
      amount: 20_000,
      payment_date: Time.current,
      payment_method: "transfer",
      transaction_type: "abono"
    )
    assert_difference "@reservation.reservation_audits.count", 1 do
      payment.update!(status: :rejected)
    end
    audit = @reservation.reservation_audits.last
    assert_equal "payment_rejected", audit.action
  end

  # ── Eliminación ───────────────────────────────────────────────────────

  test "eliminar un pago genera un audit con acción payment_deleted" do
    payment = @reservation.payments.create!(
      amount: 10_000,
      payment_date: Time.current,
      payment_method: "transfer",
      transaction_type: "abono"
    )

    # Reload needed to clear previously_changed flags from create!
    payment.reload

    assert_difference "@reservation.reservation_audits.count", 1 do
      payment.destroy
    end
    audit = @reservation.reservation_audits.last
    assert_equal "payment_deleted", audit.action
  end
end
