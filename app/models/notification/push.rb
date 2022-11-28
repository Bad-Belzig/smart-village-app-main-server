# frozen_string_literal: true

class Notification::Push < ApplicationRecord
  belongs_to :notification_pushable, polymorphic: true

  def recurring_count
    return 0 unless recurring

    # filter present weekday fields and count them
    [
      monday_at,
      tuesday_at,
      wednesday_at,
      thursday_at,
      friday_at,
      saturday_at,
      sunday_at
    ].compact.delete_if(&:blank?).count
  end
end

# == Schema Information
#
# Table name: notification_pushes
#
#  id                         :bigint           not null, primary key
#  notification_pushable_type :string(255)
#  notification_pushable_id   :bigint
#  once_at                    :datetime
#  monday_at                  :time
#  tuesday_at                 :time
#  wednesday_at               :time
#  thursday_at                :time
#  friday_at                  :time
#  saturday_at                :time
#  sunday_at                  :time
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  recurring                  :integer          default(0)
#
