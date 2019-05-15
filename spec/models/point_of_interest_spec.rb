# frozen_string_literal: true

require "rails_helper"

RSpec.describe PointOfInterest, type: :model do
  it { is_expected.to have_many(:addresses) }
  it { is_expected.to have_one(:contact) }
  it { is_expected.to have_one(:operating_company) }
  it { is_expected.to have_one(:data_provider) }
  it { is_expected.to have_many(:media_contents) }
  it { is_expected.to have_many(:web_urls) }
  it { is_expected.to have_many(:opening_hours) }
  it { is_expected.to have_many(:prices) }
  it { is_expected.to have_many(:accessibilty_informations) }
  it { is_expected.to validate_presence_of(:name) }
end

# == Schema Information
#
# Table name: attractions
#
#  id                      :bigint           not null, primary key
#  external_id             :integer
#  name                    :string(255)
#  description             :string(255)
#  mobile_description      :string(255)
#  active                  :boolean          default(TRUE)
#  length_km               :integer
#  means_of_transportation :integer
#  category_id             :bigint
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  type                    :string(255)      default("PointOfInterest"), not null
#