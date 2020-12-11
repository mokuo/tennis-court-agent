# frozen_string_literal: true

require Rails.root.join("domain/services/notification_service")

class ReservationJob < ApplicationJob
  queue_as :reservation

  def perform(reservation_frame_hash)
    reservation_frame = Yokohama::ReservationFrame.from_hash(reservation_frame_hash)
    service.reserve(reservation_frame)
  end

  private

  def service
    YokohamaService.new
  end
end
