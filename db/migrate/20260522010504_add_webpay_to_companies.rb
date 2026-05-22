class AddWebpayToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_column :companies, :webpay_commerce_code, :string
    add_column :companies, :webpay_api_key, :string
    add_column :companies, :webpay_active, :boolean, default: false
  end
end
