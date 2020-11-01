# frozen_string_literal: true

require Rails.root.join("domain/models/domain_event")
require Rails.root.join("domain/models/available_date")
require Rails.root.join("domain/models/yokohama/reservation_frame")

module Yokohama
  class ReservationStatusChecked < DomainEvent
    attribute :park_name, :string
    attribute :reservation_frame

    validates :park_name, presence: true
    validates :reservation_frame, presence: true

    def subscribers
      [
        # lambda do |e|
        #   XXXJob.dispatch_jobs(
        #     e.availability_check_identifier,
        #     e.park_name,
        #     e.reservation_frames
        #   )
        # end
      ]
    end

    def to_hash
      super.merge(reservation_frame: reservation_frame.to_hash)
    end

    def self.from_hash(hash)
      new(
        availability_check_identifier: hash[:availability_check_identifier],
        published_at: hash[:published_at],
        park_name: hash[:park_name],
        reservation_frame: ReservationFrame.from_hash(hash[:reservation_frame])
      )
    end
  end
end
