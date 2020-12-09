# frozen_string_literal: true

# == Schema Information
#
# Table name: availability_checks
#
#  id         :bigint           not null, primary key
#  identifier :string           not null
#  state      :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_availability_checks_on_identifier  (identifier) UNIQUE
#
FactoryBot.define do
  factory :availability_check do
    identifier { AvailabilityCheckIdentifier.build }
  end
end
