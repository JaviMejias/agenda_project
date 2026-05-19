require "test_helper"

class ReservationTest < ActiveSupport::TestCase
  def setup
    @property = properties(:one)
    @user = users(:one)
    @client = clients(:one)
  end

  test "should be valid with correct attributes" do
    reservation = Reservation.new(
      property: @property,
      user: @user,
      client: @client,
      start_time: 5.days.from_now.change(hour: 10),
      end_time: 6.days.from_now.change(hour: 10)
    )
    assert reservation.valid?
  end

  test "should be invalid without start_time" do
    reservation = Reservation.new(start_time: nil)
    assert_not reservation.valid?
    assert_includes reservation.errors[:start_time], "es obligatorio/a"
  end

  test "should be invalid if end_time is before start_time" do
    reservation = Reservation.new(
      start_time: 5.days.from_now,
      end_time: 4.days.from_now
    )
    assert_not reservation.valid?
    assert_includes reservation.errors[:end_time], "no puede ser anterior a la fecha de inicio"
  end

  test "should be invalid if start_time is in the past" do
    reservation = Reservation.new(
      start_time: 1.day.ago,
      end_time: 1.day.from_now
    )
    assert_not reservation.valid?
    assert_includes reservation.errors[:start_time], "no puede ser en el pasado"
  end

  test "should calculate total price for per_day property" do
    reservation = Reservation.new(
      property: @property,
      user: @user,
      start_time: 5.days.from_now.to_date,
      end_time: 7.days.from_now.to_date,
      client_name: "Test"
    )
    reservation.save!
    expected_price = 2 * @property.base_price
    assert_equal expected_price, reservation.total_price
  end

  test "should calculate total price for per_hour property" do
    property_hour = properties(:two)
    reservation = Reservation.new(
      property: property_hour,
      user: @user,
      start_time: 5.days.from_now.change(hour: 10),
      end_time: 5.days.from_now.change(hour: 13),
      client_name: "Test"
    )
    reservation.save!
    expected_price = 3 * property_hour.base_price
    assert_equal expected_price, reservation.total_price
  end

  test "should not allow overlapping reservations" do
    existing = reservations(:one)
    overlapping = Reservation.new(
      property: existing.property,
      user: @user,
      client: @client,
      start_time: existing.start_time,
      end_time: existing.end_time
    )
    assert_not overlapping.valid?
    # Use a regex or partial match for overlapping message as it contains HTML
    assert_match /La propiedad ya está reservada/, overlapping.errors[:base].first
  end

  test "should allow non-overlapping reservations" do
    existing = reservations(:one)
    non_overlapping = Reservation.new(
      property: existing.property,
      user: @user,
      client: @client,
      start_time: existing.end_time + 1.minute,
      end_time: existing.end_time + 1.day
    )
    assert non_overlapping.valid?
  end

  test "should sync client name from client" do
    reservation = Reservation.new(
      property: @property,
      user: @user,
      client: @client,
      start_time: 10.days.from_now,
      end_time: 11.days.from_now
    )
    reservation.valid?
    assert_equal @client.name, reservation.client_name
  end

  test "active scope should not include cancelled reservations" do
    active_reservations = Reservation.active
    assert_includes active_reservations, reservations(:one)
    assert_includes active_reservations, reservations(:two)
    assert_not_includes active_reservations, reservations(:three)
  end

  test "should set pending_status_timestamp on creation of pending reservation" do
    reservation = Reservation.new(
      property: @property,
      user: @user,
      client: @client,
      start_time: 5.days.from_now.change(hour: 10),
      end_time: 6.days.from_now.change(hour: 10),
      status: :pending
    )
    reservation.save!
    assert_not_nil reservation.pending_status_set_at
    assert_in_delta Time.current, reservation.pending_status_set_at, 2.seconds
  end

  test "should set pending_status_timestamp when confirmed reservation is changed back to pending" do
    reservation = reservations(:one)
    reservation.update!(status: :confirmed)
    reservation.update_columns(pending_status_set_at: nil)
    
    reservation.update!(status: :pending)
    assert_not_nil reservation.pending_status_set_at
    assert_in_delta Time.current, reservation.pending_status_set_at, 2.seconds
  end

  test "should set pending_status_timestamp when confirmed reservation dates are changed" do
    reservation = reservations(:one)
    reservation.update!(status: :confirmed)
    reservation.update_columns(pending_status_set_at: nil)
    
    # Change date which triggers automatic status reset to pending
    reservation.update!(start_time: 12.days.from_now.change(hour: 10), end_time: 13.days.from_now.change(hour: 10))
    assert reservation.pending?
    assert_not_nil reservation.pending_status_set_at
    assert_in_delta Time.current, reservation.pending_status_set_at, 2.seconds
  end

  test "should not update pending_status_timestamp when other details of pending reservation change" do
    reservation = reservations(:two) # pending
    initial_timestamp = 2.hours.ago
    reservation.update_columns(pending_status_set_at: initial_timestamp)
    
    reservation.update!(client_name: "Nuevo Nombre")
    assert_equal initial_timestamp.to_i, reservation.reload.pending_status_set_at.to_i
  end

  test "total_paid should only sum approved payments" do
    reservation = reservations(:one)
    reservation.payments.destroy_all

    # 1. Approved payment
    reservation.payments.create!(
      amount: 1000,
      payment_date: Time.current,
      payment_method: :cash,
      transaction_type: :abono
    )

    # 2. Pending payment
    reservation.payments.create!(
      amount: 500,
      payment_date: Time.current,
      payment_method: :transfer,
      transaction_type: :abono
    )

    # 3. Rejected payment
    rejected = reservation.payments.create!(
      amount: 300,
      payment_date: Time.current,
      payment_method: :transfer,
      transaction_type: :abono
    )
    rejected.update_columns(status: 2)

    assert_equal 1000, reservation.total_paid
  end
end
