# frozen_string_literal: true

require Rails.root.join("domain/services/notification_service")
require Rails.root.join("domain/models/yokohama/reservation_frame")

class ReservationJob < ApplicationJob
  queue_as :reservation
  sidekiq_options retry: 5 # ref: https://github.com/mperham/sidekiq/wiki/Advanced-Options#workers

  delegate :send_message, to: :notification_service

  rescue_from(StandardError) do |exception|
    notification_service.send_screenshot(exception.message, exception.class)

    raise exception
    # TODO: reservation_frame の state を failed にしたい
  end

  # rubocop:disable Metrics/MethodLength
  def perform(reservation_frame_hash, waiting: false)
    # HACK: ごっそり YokohamaService に移す？
    rf = Yokohama::ReservationFrame.from_hash(reservation_frame_hash)
    notification_service.send_message("`#{rf.to_human}`の予約を開始します。")
    result = yokohama_service.reserve(rf, waiting: waiting)

    reservation_frame = ReservationFrame.find(rf.id)
    if result
      reservation_frame.update!(state: :reserved)
      notification_service.send_message("`#{rf.to_human}`の予約に成功しました！")
    else
      reservation_frame.update!(state: :failed)
      notification_service.send_message("`#{rf.to_human}`の予約に失敗しました。")
    end
  end
  # rubocop:enable Metrics/MethodLength

  private

  def yokohama_service
    YokohamaService.new
  end

  def notification_service
    NotificationService.new
  end
end
