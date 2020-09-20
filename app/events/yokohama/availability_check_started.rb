# frozen_string_literal: true

module Yokohama
  class AvailabilityCheckStarted < DomainTreeEvent
    def register_subscribers
      [
        ->(event) { AvailableDatesJob.perform_jobs_later(event) }
      ]
    end
  end
end
