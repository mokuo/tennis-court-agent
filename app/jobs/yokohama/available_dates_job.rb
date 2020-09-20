# frozen_string_literal: true

module Yokohama
  class AvailableDatesJob < Gush::Job
    def self.perform_jobs_later(event)
      path = event.path
      path.planned_children.each do |planned_child|
        perform_later(path.append(planned_child))
      end
    end

    def perform(path)
      park_name = path.park
      available_dates = get_available_dates(park_name)

      filtered_available_dates = available_dates.filter { |d| AvailableDate.check_target?(d) }

      event = AvailableDatesFound.new(path, filtered_available_dates)
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
