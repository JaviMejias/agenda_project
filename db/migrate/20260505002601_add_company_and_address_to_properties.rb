class AddCompanyAndAddressToProperties < ActiveRecord::Migration[8.0]
  def change
    add_reference :properties, :company, null: true, foreign_key: true
    add_column :properties, :address, :string
  end
end
