class CreateProperties < ActiveRecord::Migration[8.0]
  def change
    create_table :properties do |t|
      t.string :name
      t.text :description
      t.decimal :base_price
      t.integer :pricing_model, default: 0
      t.string :color, default: "#4f46e5"
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
