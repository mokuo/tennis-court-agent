# frozen_string_literal: true

module Yokohama
  class AvailableDatesFound < DomainEvent
    attribute :park_name, :string
    attribute :available_dates

    def subscribers
      [
        ->(e) { ReservationFramesJob.dispatch_jobs(e) }
      ]
    end
  end
end
