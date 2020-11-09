# frozen_string_literal: true

require Rails.root.join("domain/models/available_date")

Rails.root

module Yokohama
  class ReservationFramesJob < ApplicationJob
    queue_as :yokohama

    def self.dispatch_jobs(identifier, park_name, dates)
      dates.each { |date| perform_later(identifier, park_name, date) }
    end

    def perform(identifier, park_name, date)
      service.reservation_frames(identifier, park_name, AvailableDate.new(date))
    end

    private

    def service
      YokohamaService.new
    end
  end
end
