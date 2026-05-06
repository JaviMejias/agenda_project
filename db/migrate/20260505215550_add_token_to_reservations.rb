class AddTokenToReservations < ActiveRecord::Migration[8.1]
  def change
    add_column :reservations, :token, :string
    add_index :reservations, :token, unique: true
  end
end
