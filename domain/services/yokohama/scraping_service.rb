# frozen_string_literal: true

module Yokohama
  class ScrapingService
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

    def reservation_status(reservation_frame)
      result_page = date_selection_page_with_login(reservation_frame.park_name)
                    .click_date(reservation_frame.date)
                    .click_reservation_frame(reservation_frame)
      !result_page.error_page?
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
  end
end
