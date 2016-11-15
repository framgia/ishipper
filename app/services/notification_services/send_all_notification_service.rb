class NotificationServices::SendAllNotificationService
  attr_reader :args

  def initialize args
    @owner = args[:owner]
    @recipients = args[:recipients]
    @content = args[:content]
    @invoice = args[:invoice]
    @click_action = args[:click_action]
  end

  def perform
    @recipients.each do |recipient|
      @notification = Notification.create! owner_id: @owner.id, recipient_id: recipient.id,
        content: @content, invoice_id: @invoice.id, click_action: @click_action
      user_setting = recipient.user_setting
      if @notification
        user_setting.update! unread_notification: user_setting.unread_notification + 1
        if user_setting.receive_notification?
          Notifications::SendNotificationJob.perform_later @notification, @owner,
            recipient, @content, @invoice, @click_action
        end
      end
    end
  end
end
