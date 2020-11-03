# frozen_string_literal: true

require Rails.root.join("domain/models/domain_event")
require Rails.root.join("domain/models/available_date")

module Yokohama
  class AvailableDatesFound < DomainEvent
    attribute :park_name, :string
    attribute :available_dates

    validates :park_name, presence: true
    validates :available_dates, presence: true

    def to_hash
      super.merge(
        park_name: park_name,
        available_dates: available_dates.map(&:to_date)
      )
    end

    def self.from_hash(hash)
      new(
        availability_check_identifier: hash[:availability_check_identifier],
        published_at: hash[:published_at],
        park_name: hash[:park_name],
        available_dates: hash[:available_date].map { |date| AvailableDate.new(date) }
      )
    end

    def children_finished?(domain_events)
      domain_events.any? do |e|
        availability_check_identifier == e.availability_check_identifier &&
          e.name == "Yokohama::AvailableDatesFiltered" &&
          park_name == e.park_name
      end
    end

    private

    def subscribers
      [
        lambda do |e|
          FilterAvailableDatesJob.perform_later(
            e.availability_check_identifier,
            e.park_name,
            e.available_dates.map(&:to_date)
          )
        end
      ]
    end
  end
end
