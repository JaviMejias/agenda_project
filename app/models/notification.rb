class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(read_at: nil) }
  scope :ordered, -> { order(created_at: :desc) }

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
      html: "<span id='notifications_count' class='absolute top-1.5 right-1.5 flex items-center justify-center min-w-[16px] h-[16px] px-1 text-[9px] font-black text-white bg-red-500 rounded-full border-2 border-white dark:border-slate-900'>#{user.notifications.unread.count}</span>"
    )

    broadcast_append_to(
      "notifications_#{user_id}",
      target: "notifications_signal",
      partial: "notifications/signal"
    )
  end
end
