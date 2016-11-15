class InvoiceServices::RealtimeCreateInvoiceService
  attr_reader :args

  def initialize args
    @recipients = args[:recipients]
    @invoice = args[:invoice]
  end

  def perform
    @recipients.each do |recipient|
      if recipient.online
        channel = "#{recipient.phone_number}_realtime_channel"
        data = Hash.new
        data[:invoice] = @invoice
        RealtimeBroadcastJob.perform_now channel: channel,
          action: Settings.realtime.new_invoice, data: data
      end
    end
  end
end
