# frozen_string_literal: true

require Rails.root.join("domain/models/domain_event")

module Yokohama
  class AvailabilityCheckStarted < DomainEvent
    attribute :park_names

    validates :park_names, presence: true

    def to_hash
      super.merge(park_names: park_names)
    end

    def self.from_hash(hash)
      new(
        availability_check_identifier: hash[:availability_check_identifier],
        published_at: hash[:published_at],
        park_names: hash[:park_names]
      )
    end

    def children_finished?(domain_events)
      children = domain_events.find_all do |e|
        e.availability_check_identifier == availability_check_identifier &&
          e.name == "Yokohama::AvailableDatesFound"
      end
      park_names == children.map(&:park_name)
    end

    private

    def subscribers
      [
        ->(e) { AvailableDatesJob.dispatch_jobs(e.availability_check_identifier, e.park_names) }
      ]
    end
  end
end
