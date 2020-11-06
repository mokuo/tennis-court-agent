# frozen_string_literal: true

require Rails.root.join("domain/models/available_date")

module Yokohama
  class FilterAvailableDatesJob < ApplicationJob
    queue_as :default

    def perform(identifier, park_name, dates)
      available_dates = dates.map { |date| AvailableDate.new(date) }
      service.filter_available_dates(identifier, park_name, available_dates)
    end

    private

    def service
      YokohamaService.new
    end
  end
end
