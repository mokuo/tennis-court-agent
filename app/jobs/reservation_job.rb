# frozen_string_literal: true

require Rails.root.join("domain/services/notification_service")

class ReservationJob < ApplicationJob
  queue_as :reservation

  def perform(reservation_frame_hash)
    rf = Yokohama::ReservationFrame.from_hash(reservation_frame_hash)
    result = service.reserve(rf)

    reservation_frame = ReservationFrame.find(rf.id)
    if result
      reservation_frame.update!(state: :reserved)
    else
      reservation_frame.update!(state: :failed)
    end
  end

  private

  def service
    YokohamaService.new
  end
end
