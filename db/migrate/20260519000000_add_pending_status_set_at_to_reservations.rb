class AddPendingStatusSetAtToReservations < ActiveRecord::Migration[8.1]
  def up
    add_column :reservations, :pending_status_set_at, :datetime
    
    # Inicializar registros existentes en estado pendiente (status: 0) con su updated_at
    execute "UPDATE reservations SET pending_status_set_at = updated_at WHERE status = 0"
  end

  def down
    remove_column :reservations, :pending_status_set_at
  end
end
