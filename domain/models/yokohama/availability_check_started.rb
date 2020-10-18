# frozen_string_literal: true

require Rails.root.join("domain/models/domain_event")

module Yokohama
  class AvailabilityCheckStarted < DomainEvent
    attribute :park_names

    validates :park_names, presence: true

    private

    def subscribers
      [
        ->(e) { AvailableDatesJob.dispatch_jobs(e.identifier, e.park_names) }
      ]
    end
  end
end
