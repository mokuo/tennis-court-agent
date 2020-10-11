# frozen_string_literal: true

require Rails.root.join("domain/models/available_date")

module Yokohama
  class FilterAvailableDatesJob < ApplicationJob
    queue_as :yokohama

    def self.dispatch_jobs(identifier, park_name, dates)
      avaiable_dates = dates.map { |date| AvailableDate.new(date) }
      Rails.logger.info(
        {
          identifier: identifier,
          park_name: park_name,
          avaiable_dates: avaiable_dates
        }
      )
    end
  end
end
