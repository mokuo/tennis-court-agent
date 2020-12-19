# frozen_string_literal: true

# == Schema Information
#
# Table name: reservation_frames
#
#  id                            :bigint           not null, primary key
#  availability_check_identifier :string           not null
#  end_at                        :datetime         not null
#  now                           :boolean          not null
#  park_name                     :string           not null
#  start_at                      :datetime         not null
#  state                         :integer          default("can_reserve"), not null
#  tennis_court_name             :string           not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
require Rails.root.join("domain/models/availability_check_identifier")

FactoryBot.define do
  factory :reservation_frame do
    availability_check_identifier { AvailabilityCheckIdentifier.build }
    sequence(:park_name) { |n| "park#{n}" }
    sequence(:tennis_court_name) { |n| "tennis_court#{n}" }
    start_at { Time.current }
    end_at { Time.current }
    now { [true, false].sample }
    state { ReservationFrame.states.keys.sample }
  end
end
