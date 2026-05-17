class CreateBankAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :bank_accounts do |t|
      t.references :company, null: false, foreign_key: true
      t.string :bank_name, null: false
      t.string :account_type, null: false
      t.string :account_number, null: false
      t.string :holder_name, null: false
      t.string :holder_rut, null: false
      t.string :holder_email, null: false

      t.timestamps
    end
  end
end
