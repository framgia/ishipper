class Invoices::Realtime_visibilityInvoiceJob < ActiveJob::Base
  queue_as :default

  def perform args
    args[:recipients].each do |recipient|
      channel = "#{recipient.phone_number}_realtime_channel"
      data = Hash.new
      data[:invoice] = args[:invoice]
      RealtimeBroadcastJob.perform_now channel: channel, action: args[:action], data: data
    end
  end
end
