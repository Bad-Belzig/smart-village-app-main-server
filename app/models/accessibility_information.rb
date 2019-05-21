# frozen_string_literal: true

class AccessibilityInformation < ApplicationRecord
  belongs_to :accessable, polymorphic: true
  has_many :urls, as: :web_urlable, class_name: "WebUrl"

  accepts_nested_attributes_for :urls
end

# == Schema Information
#
# Table name: accessibility_informations
#
#  id              :bigint           not null, primary key
#  description     :string(255)
#  types           :string(255)
#  accessable_type :string(255)
#  accessable_id   :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#