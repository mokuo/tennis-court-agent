# frozen_string_literal: true

require Rails.root.join("domain/services/notification_service")

class NotificationJob < ApplicationJob
  queue_as :notification

  def perform(identifier)
    reservation_frames = query_service.reservation_frames(identifier)
    notification_service.send_availabilities("横浜市", reservation_frames)
  end

  private

  def query_service
    QueryService.new
  end

  def notification_service
    NotificationService.new
  end
end
