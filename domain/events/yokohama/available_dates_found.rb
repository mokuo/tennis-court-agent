# frozen_string_literal: true

module Yokohama
  class AvailableDatesFound < DomainEvent
    attribute :service, default: JobDispatchService.new
    attribute :park_name, :string
    attribute :available_dates

    def subscribers
      [
        ->(e) { service.dispatch_reservation_frames_jobs(e) }
      ]
    end

    def to_json(*_args)
      {
        park_name: park_name,
        available_dates: available_dates.map(&:to_json)
      }
    end
  end
end
