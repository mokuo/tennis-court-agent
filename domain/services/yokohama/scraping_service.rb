# frozen_string_literal: true

require Rails.root.join("domain/services/notification_service")

module Yokohama
  class ScrapingService
    class InvalidWaitingSeconds < StandardError; end

    def available_dates(park_name)
      ds_page = date_selection_page(park_name)
      available_dates = ds_page.available_dates
      next_page = ds_page.click_next_month

      if next_page.error_page?
        available_dates
      else
        available_dates + next_page.available_dates
      end
    end

    def reservation_frames(park_name, date)
      reservation_frames = date_selection_page_with_login(park_name)
                           .click_date(date)
                           .reservation_frames
      reservation_frames.map do |rf|
        rf.park_name = park_name
        rf
      end
    end

    def reservation_status(park_name, reservation_frame)
      result_page = date_selection_page_with_login(park_name)
                    .click_date(reservation_frame.date)
                    .click_reservation_frame(reservation_frame)
      !result_page.error_page?
    end

    def reserve(reservation_frame, waiting: false)
      reservation_frame_selection_page = date_selection_page_with_login(reservation_frame.park_name)
                                         .click_date(reservation_frame.date)
      wait_for_opeing_hour(reservation_frame) if waiting

      reservation_frame_selection_page
        .click_reservation_frame(reservation_frame)
        .click_next
        .click_next
        .reserve
        .success?
    end

    private

    def date_selection_page(park_name)
      Yokohama::TopPage.open
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park(park_name)
                       .click_tennis_court
    end

    def date_selection_page_with_login(park_name)
      Yokohama::TopPage.open
                       .login
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park(park_name)
                       .click_tennis_court
    end

    def wait_for_opeing_hour(reservation_frame)
      wait_sec = Date.current.beginning_of_day + reservation_frame.opening_hour.hours - Time.current
      raise InvalidWaitingSeconds if wait_sec > 30

      notification_service.send_screenshot("sleep(#{wait_sec})", reservation_frame.to_human)
      sleep(wait_sec)
    end

    def notification_service
      NotificationService.new
    end
  end
end
