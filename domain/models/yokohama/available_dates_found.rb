# frozen_string_literal: true

require Rails.root.join("domain/models/domain_event")
require Rails.root.join("domain/models/available_date")

module Yokohama
  class AvailableDatesFound < DomainEvent
    attribute :park_name, :string
    attribute :available_dates

    validates :park_name, presence: true
    validates :available_dates, presence: true

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

    def to_hash
      attributes.symbolize_keys.merge(
        name: self.class.to_s,
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
  end
end
