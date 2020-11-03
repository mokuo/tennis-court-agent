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

    private

    def subscribers
      []
    end
  end
end