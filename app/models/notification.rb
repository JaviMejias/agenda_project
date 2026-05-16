class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(read_at: nil) }
  scope :ordered, -> { order(created_at: :desc) }

  def self.mark_as_read_for_notifiable(notifiable, user)
    user.notifications.unread.where(notifiable: notifiable).update_all(read_at: Time.current)
  end

  def self.mark_all_as_read_for_user(user)
    user.notifications.unread.update_all(read_at: Time.current)
  end

  after_create_commit :broadcast_notification

  private

  def broadcast_notification
    broadcast_remove_to("notifications_#{user_id}", target: "no-notifications")

    broadcast_prepend_to(
      "notifications_#{user_id}",
      target: "notifications_list",
      partial: "notifications/notification",
      locals: { notification: self }
    )

    broadcast_replace_to(
      "notifications_#{user_id}",
      target: "notifications_count",
      partial: "notifications/count_badge",
      locals: { count: user.notifications.unread.count }
    )

    broadcast_append_to(
      "notifications_#{user_id}",
      target: "notifications_signal",
      partial: "notifications/signal"
    )
  end
end
