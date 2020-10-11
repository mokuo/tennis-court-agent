# frozen_string_literal: true

require Rails.root.join("domain/services/yokohama/scraping_service")
require Rails.root.join("domain/models/available_date")

module Yokohama
  class AvailableDatesJob < ApplicationJob
    queue_as :yokohama

    def self.dispatch_jobs(identifier, park_names)
      park_names.each { |park_name| perform_later(identifier, park_name) }
    end

    def perform(identifier, park_name, service = ScrapingService.new, event_class = AvailableDatesFound)
      available_dates = service.available_dates(park_name)
      event = event_class.new(
        availability_check_identifier: identifier,
        park_name: park_name,
        available_dates: available_dates
      )
      event.publish!
    end
  end
end
