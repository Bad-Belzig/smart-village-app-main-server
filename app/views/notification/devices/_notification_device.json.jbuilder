# frozen_string_literal: true

json.extract! notification_device, :id, :token, :device_type, :created_at, :updated_at, :exclude_data_provider_ids
json.url notification_device_url(notification_device, format: :json)
