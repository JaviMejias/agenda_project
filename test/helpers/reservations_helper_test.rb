require "test_helper"

class ReservationsHelperTest < ActionView::TestCase
  include ReservationsHelper

  def setup
    @reservation = reservations(:one)
    @payment = payments(:one)
  end

  test "should return correct pdf status color" do
    assert_equal "#d97706", reservation_status_pdf_color("pending")
    assert_equal "#059669", reservation_status_pdf_color("confirmed")
    assert_equal "#e11d48", reservation_status_pdf_color("cancelled")
    assert_equal "#6b7280", reservation_status_pdf_color("unknown")
  end

  test "should return correct pdf status bg" do
    assert_equal "#fffbeb", reservation_status_pdf_bg("pending")
    assert_equal "#f0fdf4", reservation_status_pdf_bg("confirmed")
    assert_equal "#fff1f2", reservation_status_pdf_bg("cancelled")
    assert_equal "#f9fafb", reservation_status_pdf_bg("unknown")
  end

  test "should return correct receipt status style" do
    assert_includes receipt_status_style("pending"), "color: #d97706"
    assert_includes receipt_status_style("confirmed"), "color: #059669"
    assert_includes receipt_status_style("cancelled"), "color: #e11d48"
    assert_includes receipt_status_style("completed"), "color: #4338ca"
  end

  test "should return correct receipt status label" do
    assert_equal "Pendiente", receipt_status_label("pending")
    assert_equal "Confirmada", receipt_status_label("confirmed")
    assert_equal "Cancelada", receipt_status_label("cancelled")
    assert_equal "Completada", receipt_status_label("completed")
    assert_equal "Unknown", receipt_status_label("unknown")
  end

  test "should return correct payment method label" do
    @payment.payment_method = :transfer
    assert_equal "Transferencia", payment_method_label(@payment)

    @payment.payment_method = :cash
    assert_equal "Efectivo", payment_method_label(@payment)

    @payment.payment_method = :card
    assert_equal "Tarjeta", payment_method_label(@payment)

    @payment.payment_method = :other
    assert_equal "Depósito / Otro", payment_method_label(@payment)
  end

  test "should return correct payment method icon" do
    @payment.payment_method = :transfer
    assert_equal "fa-money-bill-transfer", payment_method_icon(@payment)

    @payment.payment_method = :cash
    assert_equal "fa-money-bill", payment_method_icon(@payment)

    @payment.payment_method = :card
    assert_equal "fa-credit-card", payment_method_icon(@payment)

    @payment.payment_method = :other
    assert_equal "fa-money-check", payment_method_icon(@payment)
  end

  test "should return correct reservation status badge classes" do
    @reservation.status = "confirmed"
    assert_includes reservation_status_badge_classes(@reservation), "text-emerald-600"

    @reservation.status = "pending"
    assert_includes reservation_status_badge_classes(@reservation), "text-amber-600"

    @reservation.status = "cancelled"
    assert_includes reservation_status_badge_classes(@reservation), "text-rose-600"
  end
end
