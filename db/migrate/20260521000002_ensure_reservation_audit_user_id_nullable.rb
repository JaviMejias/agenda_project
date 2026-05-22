class EnsureReservationAuditUserIdNullable < ActiveRecord::Migration[8.1]
  def change
    # user_id must be nullable: public clients trigger payment events
    # without a logged-in user. author_name handles attribution instead.
    change_column_null :reservation_audits, :user_id, true
  end
end
