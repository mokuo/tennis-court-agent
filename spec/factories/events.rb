# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                            :bigint           not null, primary key
#  availability_check_identifier :string(255)      not null
#  contents                      :json
#  name                          :string(255)      not null
#  published_at                  :datetime         not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#

require Rails.root.join("domain/models/availability_check_identifier")

FactoryBot.define do
  factory :event do
    availability_check_identifier { AvailabilityCheckIdentifier.build }
    contents { |n| { some_attribute: "hoge#{n}" } }
    sequence(:name) { |n| "event#{n}" }
    published_at { Time.current }
  end
end
