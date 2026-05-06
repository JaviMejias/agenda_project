class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :rut
      t.string :business_type
      t.string :address
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
