class AddContactFieldsToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_column :companies, :phone, :string
    add_column :companies, :email, :string
  end
end
