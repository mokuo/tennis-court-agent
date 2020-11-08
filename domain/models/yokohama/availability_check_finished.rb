# frozen_string_literal: true

require Rails.root.join("domain/models/domain_event")

module Yokohama
  class AvailabilityCheckFinished < DomainEvent
    def self.from_hash(hash)
      new(
        availability_check_identifier: hash[:availability_check_identifier],
        published_at: hash[:published_at]
      )
    end

    def children_finished?(_domain_events)
      true
    end

    private

    def subscribers
      [
        ->(e) { NotificationJob.perform_later(e.availability_check_identifier) }
      ]
    end
  end
end
