class OperationalTask < ApplicationRecord
  belongs_to :reservation

  enum :task_type, { other: 0, check_in: 1, check_out: 2, cleaning: 3 }

  validates :name, presence: true

  after_update_commit -> { broadcast_replace_to "reservation_#{reservation.id}_tasks", target: self, partial: "operational_tasks/operational_task", locals: { task: self } }
  after_create_commit -> { broadcast_append_to "reservation_#{reservation.id}_tasks", target: "operational_tasks_list", partial: "operational_tasks/operational_task", locals: { task: self } }
  after_destroy_commit -> { broadcast_remove_to "reservation_#{reservation.id}_tasks", target: self }
end
