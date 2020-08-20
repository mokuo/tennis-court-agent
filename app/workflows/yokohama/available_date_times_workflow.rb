# frozen_string_literal: true

module Yokohama
  class AvailableDateTimesWorkflow < Gush::Workflow
    def configure(park_name, available_dates)
      available_dates.map do |available_date|
        run AvailableDateTimesJob, params: { park_name: park_name, available_date: available_date }
      end
    end
  end
end
