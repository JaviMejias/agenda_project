class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :reservations do |t|
      t.references :property, null: false, foreign_key: true
      t.string :client_name
      t.datetime :start_time
      t.datetime :end_time
      t.integer :status, default: 0
      t.decimal :total_price

      t.timestamps
    end
  end
end
