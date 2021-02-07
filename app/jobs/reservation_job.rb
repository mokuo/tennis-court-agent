# frozen_string_literal: true

require Rails.root.join("domain/services/notification_service")
require Rails.root.join("domain/models/yokohama/reservation_frame")

class ReservationJob < ApplicationJob
  queue_as :reservation
  sidekiq_options retry: 5 # ref: https://github.com/mperham/sidekiq/wiki/Advanced-Options#workers

  delegate :send_message, to: :notification_service

  rescue_from(StandardError) do |exception|
    begin
      # NOTE: ここでエラーになると、元のエラーがわからなくなるので、rescue しておく
      notification_service.send_screenshot(exception.message, exception.class)
    rescue StandardError => e
      # HACK: backtrace はテキストファイルをアップロードした方が良さそう
      notification_service.send_message(e.inspect)
      notification_service.send_message(e.backtrace)
    end

    raise exception
    # TODO: reservation_frame の state を failed にしたい
  end

  def perform(reservation_frame_hash, waiting: false)
    rf = Yokohama::ReservationFrame.from_hash(reservation_frame_hash)
    yokohama_service.reserve(rf, waiting: waiting)
  end

  private

  def yokohama_service
    YokohamaService.new
  end

  def notification_service
    NotificationService.new
  end
end
