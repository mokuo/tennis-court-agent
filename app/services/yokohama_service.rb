# frozen_string_literal: true

require Rails.root.join("domain/services/yokohama/scraping_service")
require Rails.root.join("domain/models/available_date")
require Rails.root.join("domain/models/yokohama/available_dates_found")
require Rails.root.join("domain/models/yokohama/available_dates_filtered")
require Rails.root.join("domain/models/yokohama/reservation_frames_found")
require Rails.root.join("domain/models/yokohama/reservation_status_checked")
require Rails.root.join("domain/models/yokohama/availability_check_finished")

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

  def reservation_frames(identifier, park_name, available_date)
    reservation_frames = @scraping_service.reservation_frames(park_name, available_date.to_date)
    event = Yokohama::ReservationFramesFound.new(
      availability_check_identifier: identifier,
      available_date: available_date,
      reservation_frames: reservation_frames
    )
    event.publish!
  end

  def reservation_status(identifier, reservation_frame)
    now = @scraping_service.reservation_status(reservation_frame)
    reservation_frame.now = now
    event = Yokohama::ReservationStatusChecked.new(
      availability_check_identifier: identifier,
      reservation_frame: reservation_frame
    )
    event.publish!
  end

  def inspect_events(identifier)
    events = Event.where(availability_check_identifier: identifier)
    domain_events = events.map(&:to_domain_event)
    return unless domain_events.all? { |e| e.children_finished?(domain_events) }

    event = Yokohama::AvailabilityCheckFinished.new(
      availability_check_identifier: identifier
    )
    event.publish!
  end
end
