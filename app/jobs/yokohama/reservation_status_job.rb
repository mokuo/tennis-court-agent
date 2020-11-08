# frozen_string_literal: true

require Rails.root.join("domain/models/yokohama/reservation_frame")

module Yokohama
  class ReservationStatusJob < ApplicationJob
    queue_as :yokohama

    def self.dispatch_jobs(identifier, park_name, reservation_frames)
      reservation_frames.each do |reservation_frame|
        perform_later(identifier, park_name, reservation_frame.to_hash)
      end
    end

    def perform(identifier, park_name, reservation_frame_hash)
      reservation_frame = Yokohama::ReservationFrame.from_hash(reservation_frame_hash)
      service.reservation_status(identifier, park_name, reservation_frame)
    end

    private

    def service
      YokohamaService.new
    end
  end
end
