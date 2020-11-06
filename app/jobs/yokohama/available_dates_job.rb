# frozen_string_literal: true

require Rails.root.join("domain/models/available_date")

module Yokohama
  class AvailableDatesJob < ApplicationJob
    queue_as :default

    def self.dispatch_jobs(identifier, park_names)
      park_names.each { |park_name| perform_later(identifier, park_name) }
    end

    def perform(identifier, park_name)
      service.available_dates(identifier, park_name)
    end

    private

    def service
      YokohamaService.new
    end
  end
end
