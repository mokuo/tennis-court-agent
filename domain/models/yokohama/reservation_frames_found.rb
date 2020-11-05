# frozen_string_literal: true

require Rails.root.join("domain/models/domain_event")
require Rails.root.join("domain/models/available_date")

module Yokohama
  class ReservationFramesFound < DomainEvent
    attribute :available_date
    attribute :reservation_frames

    validates :available_date, presence: true
    validates :reservation_frames, presence: true

    def to_hash
      attributes.symbolize_keys.merge(
        name: self.class.to_s,
        available_date: available_date.to_date,
        reservation_frames: reservation_frames.map(&:to_hash)
      )
    end

    def self.from_hash(hash)
      new(
        availability_check_identifier: hash[:availability_check_identifier],
        published_at: hash[:published_at],
        available_date: AvailableDate.new(hash[:available_date]),
        reservation_frames: hash[:reservation_frames].map { |r| ReservationFrame.from_hash(r.symbolize_keys) }
      )
    end

    def children_finished?(domain_events)
      children = domain_events.find_all do |e|
        e.availability_check_identifier == availability_check_identifier &&
          e.name == "Yokohama::ReservationStatusChecked"
      end
      reservation_frames.size == children.size
    end

    private

    def subscribers
      [
        lambda do |e|
          ReservationStatusJob.dispatch_jobs(
            e.availability_check_identifier,
            e.reservation_frames
          )
        end
      ]
    end
  end
end
