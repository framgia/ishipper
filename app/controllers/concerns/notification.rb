module Notification
  require "uri"
  require "net/http"
  require "net/https"

  $uri = URI.parse "https://fcm.googleapis.com/fcm/send"
  $https = Net::HTTP.new $uri.host, $uri.port
  $https.use_ssl = true
  $https.verify_mode = OpenSSL::SSL::VERIFY_NONE
  $request = Net::HTTP::Post.new $uri.path

  $request.add_field "Content-Type", "Authorization"
  $request["Content-Type"] = "application/json"
  $request["Authorization"] = "key=AIzaSyCOTxhxhNqU1araxpzQxe8C-S_qSNAbz5U"

  def set_data_notification notification_token, title, body, invoice_id, user_send_id, user_receive_id
    scope =  Hash.new
    scope[:notification_token] = notification_token
    scope[:title] = title
    scope[:body] = body
    scope[:invoice_id] = invoice_id
    scope[:user_send_id] = user_send_id
    scope[:user_receive_id] = user_receive_id
    scope
  end

  def send_notification scope
    $request.body = {
      registration_ids: ["#{scope[:notification_token]}"],
      notification: {
        title: scope[:title],
        body: scope[:body],
      },
      data: {
        invoice_id: scope[:invoice_id],
        user_send_id: scope[:user_send_id],
        user_receive_id: scope[:user_receive_id]
      },
      time_to_live: 3600,
      priority: "HIGH"
    }
    $request.body = $request.body.to_json
    response = $https.request $request
  end
end
