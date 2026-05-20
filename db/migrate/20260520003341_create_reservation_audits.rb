class CreateReservationAudits < ActiveRecord::Migration[8.1]
  def change
    create_table :reservation_audits do |t|
      t.references :reservation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :author_name
      t.string :action
      t.jsonb :details

      t.timestamps
    end
  end
end
