# frozen_string_literal: true

require Rails.root.join("domain/services/yokohama/scraping_service")
require Rails.root.join("domain/models/available_date")
require Rails.root.join("domain/events/yokohama/available_dates_found")
require Rails.root.join("domain/events/yokohama/available_dates_filtered")

class YokohamaService
  def initialize(scraping_service = Yokohama::ScrapingService.new)
    @scraping_service = scraping_service
  end

  def available_dates(identifier, park_name)
    available_dates = @scraping_service.available_dates(park_name)
    event = Yokohama::AvailableDatesFound.new(
      availability_check_identifier: identifier,
      park_name: park_name,
      available_dates: available_dates
    )
    event.publish!
  end

  def filter_available_dates(identifier, park_name, available_dates)
    filtered_available_dates = available_dates.filter(&:check_target?)
    event = Yokohama::AvailableDatesFiltered.new(
      availability_check_identifier: identifier,
      park_name: park_name,
      available_dates: filtered_available_dates
    )
    event.publish!
  end
end