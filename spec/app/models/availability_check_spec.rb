# frozen_string_literal: true

# == Schema Information
#
# Table name: availability_checks
#
#  id         :bigint           not null, primary key
#  identifier :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_availability_checks_on_identifier  (identifier) UNIQUE
#
RSpec.describe AvailabilityCheck, type: :model do
  it "has a valid factory" do
    availability_check = build(:availability_check)
    expect(availability_check).to be_valid
  end
end
