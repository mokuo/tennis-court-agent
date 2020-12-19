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
require Rails.root.join("domain/models/yokohama/reservation_frame")

class ReservationFrame < ApplicationRecord
  enum state: { can_reserve: 0, will_reserve: 1, reserving: 2, reserved: 3, failed: 9 }

  def self.from_domain_model(reservation_frame)
    new(
      end_at: reservation_frame.end_date_time,
      now: reservation_frame.now,
      park_name: reservation_frame.park_name,
      start_at: reservation_frame.start_date_time,
      tennis_court_name: reservation_frame.tennis_court_name
    )
  end

  def to_domain_model
    Yokohama::ReservationFrame.new(
      park_name: park_name,
      tennis_court_name: tennis_court_name,
      start_date_time: start_at,
      end_date_time: end_at,
      now: now,
      state: state,
      id: id
    )
  end
end
