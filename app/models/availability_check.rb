# frozen_string_literal: true

# == Schema Information
#
# Table name: availability_checks
#
#  id         :bigint           not null, primary key
#  identifier :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_availability_checks_on_identifier  (identifier) UNIQUE
#
class AvailabilityCheck < ApplicationRecord
  validates :identifier, presence: true
end
