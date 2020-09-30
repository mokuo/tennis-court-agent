# frozen_string_literal: true

require Rails.root.join("domain/models/available_date")

module Yokohama
  class AvailableDatesJob < ApplicationJob
    queue_as :yokohama

    def perform(park_name, service = ScrapingService.new)
      available_dates = service.available_dates(park_name)
      event = AvailableDatesFound.new(park_name, available_dates)
      event.publish!
    end
  end
end
