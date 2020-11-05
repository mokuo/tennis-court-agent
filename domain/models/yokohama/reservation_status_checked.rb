# frozen_string_literal: true

require Rails.root.join("domain/models/domain_event")
require Rails.root.join("domain/models/available_date")
require Rails.root.join("domain/models/yokohama/reservation_frame")

module Yokohama
  class ReservationStatusChecked < DomainEvent
    attribute :reservation_frame

    validates :reservation_frame, presence: true

    def to_hash
      super.merge(reservation_frame: reservation_frame.to_hash)
    end

    def self.from_hash(hash)
      new(
        availability_check_identifier: hash[:availability_check_identifier],
        published_at: hash[:published_at],
        reservation_frame: ReservationFrame.from_hash(hash[:reservation_frame])
      )
    end

    def children_finished?(_domain_events)
      true
    end

    private

    def subscribers
      [
        lambda do |e|
          InspectEventsJob.perform_later(e.availability_check_identifier)
        end
      ]
    end
  end
end
