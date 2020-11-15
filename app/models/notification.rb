# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications
#
#  id                            :bigint           not null, primary key
#  availability_check_identifier :string           not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_notifications_on_availability_check_identifier  (availability_check_identifier) UNIQUE
#
class Notification < ApplicationRecord
  validates :availability_check_identifier, presence: true
end
