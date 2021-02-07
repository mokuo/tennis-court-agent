# frozen_string_literal: true

require Rails.root.join("domain/services/yokohama/scraping_service")
require Rails.root.join("domain/services/notification_service")
require Rails.root.join("domain/models/available_date")
require Rails.root.join("domain/models/availability_check_identifier")
require Rails.root.join("domain/models/yokohama/availability_check_started")
require Rails.root.join("domain/models/yokohama/available_dates_found")
require Rails.root.join("domain/models/yokohama/available_dates_filtered")
require Rails.root.join("domain/models/yokohama/reservation_frames_found")
require Rails.root.join("domain/models/yokohama/reservation_status_checked")
require Rails.root.join("domain/models/yokohama/availability_check_finished")

class YokohamaService
  def initialize(scraping_service = Yokohama::ScrapingService.new, notification_service = NotificationService.new)
    @scraping_service = scraping_service
    @notification_service = notification_service
  end

  def start_availability_check
    park_names = %w[富岡西公園 三ツ沢公園 新杉田公園]

    identifier = AvailabilityCheckIdentifier.build
    AvailabilityCheck.create!(identifier: identifier)

    event = Yokohama::AvailabilityCheckStarted.new(
      availability_check_identifier: identifier,
      park_names: park_names
    )
    event.publish!
  end

  def available_dates(identifier, park_name)
    available_dates = scraping_service.available_dates(park_name)
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
    reservation_frames = scraping_service.reservation_frames(park_name, available_date.to_date)
    event = Yokohama::ReservationFramesFound.new(
      availability_check_identifier: identifier,
      park_name: park_name,
      available_date: available_date,
      reservation_frames: reservation_frames
    )
    event.publish!
  end

  def reservation_status(identifier, park_name, reservation_frame)
    now = scraping_service.reservation_status(park_name, reservation_frame)
    reservation_frame.now = now
    event = Yokohama::ReservationStatusChecked.new(
      availability_check_identifier: identifier,
      park_name: park_name,
      reservation_frame: reservation_frame
    )
    event.publish!
  end

  def inspect_events(identifier)
    events = Event.where(availability_check_identifier: identifier)
    domain_events = events.map(&:to_domain_event)
    return unless domain_events.all? { |e| e.children_finished?(domain_events) }

    # 悲観的ロック
    availability_check = AvailabilityCheck.lock.find_by!(identifier: identifier)
    return if availability_check.finished?

    event = Yokohama::AvailabilityCheckFinished.new(
      availability_check_identifier: identifier
    )
    event.publish!
    availability_check.update!(state: :finished)
  end

  def reserve(reservation_frame, waiting: false)
    notification_service.send_message("`#{reservation_frame.to_human}` の予約を開始します。")
    is_success = scraping_service.reserve(reservation_frame, waiting: waiting)

    rf = ReservationFrame.find(reservation_frame.id)
    if is_success
      rf.update!(state: :reserved)
      notification_service.send_message("`#{reservation_frame.to_human}` の予約に成功しました！")
    else
      rf.update!(state: :failed)
      notification_service.send_screenshot("`#{reservation_frame.to_human}` の予約に失敗しました。")
    end
  end

  private

  attr_reader :scraping_service, :notification_service
end
