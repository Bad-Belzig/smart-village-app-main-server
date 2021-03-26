class WasteNotificationJob
  def self.perform(waste_registration_id, waste_pickup_time_id)
    waste_pickup_time = Waste::PickUpTime.find_by(id: waste_pickup_time_id)
    registration_to_check = Waste::DeviceRegistration.find_by(id: waste_registration_id)
    static_content = StaticContent.find_by(name: "wasteTypes")
    return if static_content.blank?
    return if waste_pickup_time.blank?
    return if waste_pickup_time.pickup_date.blank?

    waste_types = JSON.parse(static_content.content)
    device = registration_to_check.notification_device
    return unless device.present?

    # Message to send
    title = "Abfallkalender"
    parsed_date = Date.parse(waste_pickup_time.pickup_date).strftime("%d.%m.%Y")
    body = "#{registration_to_check.street}: Am #{parsed_date} wird #{waste_types[registration_to_check.notify_for_waste_type]["label"]} abgeholt."
    message_options = { title: title, body: body }
    messages = [message_options.merge(to: device.token)]

    # sending message
    client = Exponent::Push::Client.new
    feedback = client.send_messages(messages)

    # Log PushNotification
    RedisAdapter.add_push_log(device.token, message_options.merge(date: DateTime.now, payload: feedback.try(:response).try(:body)))
  end
end
