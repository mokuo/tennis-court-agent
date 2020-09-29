# frozen_string_literal: true

module Yokohama
  class AvailableDatesJob < ApplicationJob
    def perform(path)
      available_dates = get_available_dates(path.park)
      event = AvailableDatesFound.new(path, available_dates)
      event.publish
    end

    private

    def get_available_dates(park_name)
      Yokohama::TopPage.open
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park(park_name)
                       .click_tennis_court
                       .available_dates
    end
  end
end
