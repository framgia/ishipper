class NotificationServices::CreateNotificationService
  attr_reader :args

  def initialize args
    @owner = args[:owner]
    @recipient = args[:recipient]
    @content = args[:content]
    @invoice = args[:invoice]
    @click_action = args[:click_action]
  end

  def perform
    @notification = Notification.create! owner_id: @owner.id, recipient_id: @recipient.id,
      content: @content, invoice_id: @invoice.id, click_action: @click_action
    user_setting = @recipient.user_setting
    if @notification
      user_setting.update! unread_notification: user_setting.unread_notification + 1
      if @recipient.online
        channel = "#{@recipient.phone_number}_realtime_channel"
        data = Hash.new
        data[:unread_notification] = user_setting.unread_notification
        RealtimeBroadcastJob.perform_now channel: channel,
          action: Settings.realtime.unread_notification, data: data
      end
      if user_setting.receive_notification?
        Notifications::SendNotificationJob.perform_now @notification, @owner,
          @recipient, @content, @invoice, @click_action
      end
    end
  end
end
