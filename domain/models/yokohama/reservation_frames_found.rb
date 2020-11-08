# frozen_string_literal: true

require Rails.root.join("domain/models/domain_event")
require Rails.root.join("domain/models/available_date")

module Yokohama
  class ReservationFramesFound < DomainEvent
    attribute :park_name, :string
    attribute :available_date
    attribute :reservation_frames

    validates :park_name, presence: true
    validates :available_date, presence: true
    # HACK: 空配列だとバリデーションエラーになるので、一旦バリデーションをかけない
    # validates :reservation_frames, presence: true

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
        park_name: hash[:park_name],
        available_date: AvailableDate.new(hash[:available_date]),
        reservation_frames: hash[:reservation_frames].map { |r| ReservationFrame.from_hash(r.symbolize_keys) }
      )
    end

    def children_finished?(domain_events)
      return true if reservation_frames.blank?

      reservation_frames.all? { |rf| child_finished?(rf, domain_events) }
    end

    private

    def subscribers
      [
        lambda do |e|
          ReservationStatusJob.dispatch_jobs(
            e.availability_check_identifier,
            e.park_name,
            e.reservation_frames
          )
        end
      ]
    end

    def child_finished?(reservation_frame, domain_events)
      domain_events.any? do |e|
        e.availability_check_identifier == availability_check_identifier &&
          e.name == "Yokohama::ReservationStatusChecked" &&
          e.reservation_frame.eql_frame?(reservation_frame)
      end
    end
  end
end
