class CreateOperationalTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :operational_tasks do |t|
      t.references :reservation, null: false, foreign_key: true
      t.string :name
      t.integer :task_type
      t.boolean :is_completed

      t.timestamps
    end
  end
end
