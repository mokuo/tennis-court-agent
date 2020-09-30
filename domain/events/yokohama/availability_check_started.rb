# frozen_string_literal: true

require Rails.root.join("domain/events/domain_event")

module Yokohama
  class AvailabilityCheckStarted < DomainEvent
    attribute :service, default: JobDispatchService.new

    private

    def subscribers
      [
        ->(e) { service.dispatch_available_dates_jobs(e) }
      ]
    end
  end
end
