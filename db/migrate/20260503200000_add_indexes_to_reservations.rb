class AddIndexesToReservations < ActiveRecord::Migration[8.0]
  def change
    add_index :reservations, :start_time
    add_index :reservations, :end_time
    add_index :reservations, :status
  end
end
