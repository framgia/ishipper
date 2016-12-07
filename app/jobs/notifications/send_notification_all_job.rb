class Notifications::SendNotificationAllJob < ActiveJob::Base
  queue_as :default

  def perform args
    args[:recipients].each do |recipient|
      NotificationServices::CreateNotificationService.new(owner: args[:owner],
        recipient: recipient, status: args[:status], invoice: args[:invoice],
        click_action: [:click_action]).perform
    end
  end
end
