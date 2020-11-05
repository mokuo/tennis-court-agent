# frozen_string_literal: true

require Rails.root.join("domain/models/yokohama/reservation_frame")

module Yokohama
  class ReservationStatusJob < ApplicationJob
    def self.dispatch_jobs(identifier, reservation_frames)
      reservation_frames.each do |reservation_frame|
        perform_later(identifier, reservation_frame.to_hash)
      end
    end

    def perform(identifier, reservation_frame_hash)
      reservation_frame = Yokohama::ReservationFrame.from_hash(reservation_frame_hash)
      service.reservation_status(identifier, reservation_frame)
    end

    private

    def service
      YokohamaService.new
    end
  end
end
