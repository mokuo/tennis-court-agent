# frozen_string_literal: true

class NotificationJob < ApplicationJob
  queue_as :default

  def perform(identifier)
    reservation_frames = query_service.reservation_frames(identifier)
    notification_service.send_availabilities("横浜市", reservation_frames)
  end

  private

  def query_service
    QueryService.new
  end

  def notification_service
    NotifiactionService.new
  end
end
