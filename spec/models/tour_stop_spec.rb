# frozen_string_literal: true

require "rails_helper"

RSpec.describe TourStop, type: :model do
  it { is_expected.to have_one(:tour) }
end

# == Schema Information
#
# Table name: attractions
#
#  id                      :bigint           not null, primary key
#  external_id             :integer
#  name                    :string(255)
#  description             :text(65535)
#  mobile_description      :text(65535)
#  active                  :boolean          default(TRUE)
#  length_km               :integer
#  means_of_transportation :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  type                    :string(255)      default("PointOfInterest"), not null
#  data_provider_id        :integer
#  visible                 :boolean          default(TRUE)
#  payload                 :text(65535)
#
