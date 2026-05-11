class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [ :update, :destroy ]

  def index
    @pagy, @notifications = pagy(current_user.notifications.ordered, limit: 20)
  end

  def update
    @notification.update(read_at: Time.current)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def destroy
    @notification.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end
end
