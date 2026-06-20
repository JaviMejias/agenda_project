class MakeIncidentReservationOptional < ActiveRecord::Migration[8.1]
  def change
    change_column_null :incidents, :reservation_id, true
  end
end
