class AddOperationNumberToPayments < ActiveRecord::Migration[8.1]
  def change
    add_column :payments, :operation_number, :string
  end
end
