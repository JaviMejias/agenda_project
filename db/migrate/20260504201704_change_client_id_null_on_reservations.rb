class ChangeClientIdNullOnReservations < ActiveRecord::Migration[8.0]
  def change
    change_column_null :reservations, :client_id, true
  end
end
