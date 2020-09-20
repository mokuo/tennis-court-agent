# frozen_string_literal: true

module Yokohama
  class AvailableDatesFound < DomainTreeEvent
    def register_subscribers
      [
        ->(event) { ReservationFramesJob.perform_jobs_later(event) }
      ]
    end
  end
end
