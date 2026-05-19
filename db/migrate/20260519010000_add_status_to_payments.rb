class AddStatusToPayments < ActiveRecord::Migration[8.1]
  def change
    add_column :payments, :status, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        # 1. Auto-approve all existing cash and card payments (payment_method 1 and 2)
        execute "UPDATE payments SET status = 1 WHERE payment_method IN (1, 2)"

        # 2. Auto-approve all transfer payments associated with confirmed reservations (status 1)
        execute "UPDATE payments SET status = 1 FROM reservations WHERE payments.reservation_id = reservations.id AND reservations.status = 1"
      end
    end
  end
end
