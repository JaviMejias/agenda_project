class CreateExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :expenses do |t|
      t.references :property, null: false, foreign_key: true
      t.decimal :amount
      t.date :expense_date
      t.integer :category
      t.string :description

      t.timestamps
    end
  end
end
