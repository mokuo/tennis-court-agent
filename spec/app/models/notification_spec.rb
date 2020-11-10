# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications
#
#  id         :bigint           not null, primary key
#  identifier :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_notifications_on_identifier  (identifier) UNIQUE
#

RSpec.describe Notification, type: :model do
  it "has a valid factory" do
    notification = build(:notification)
    expect(notification).to be_valid
  end
end
