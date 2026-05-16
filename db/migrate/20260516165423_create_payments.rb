class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :reservation, null: false, foreign_key: true
      t.decimal :amount
      t.datetime :payment_date
      t.integer :payment_method
      t.integer :transaction_type
      t.text :notes

      t.timestamps
    end
  end
end
