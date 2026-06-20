class CreateIncidents < ActiveRecord::Migration[8.1]
  def change
    create_table :incidents do |t|
      t.references :property, null: false, foreign_key: true
      t.references :reservation, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :status
      t.integer :severity

      t.timestamps
    end
  end
end
