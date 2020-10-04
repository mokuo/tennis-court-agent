# frozen_string_literal: true

class NotificationJob < ApplicationJob
  queue_as :notification

  # TODO: NotifiactionService を使う
  def perform
    reservation_frames = payloads.map { |p| p[:output][:reservation_frame] }
    message = build_message(params[:park_name], reservation_frames)
    notification.send(message)
  end

  private

  def notification
    params[:notification] || Notification.new
  end

  # TODO: Domain::NotificationService に移動したので削除
  def build_message(park_name, reservation_frames)
    msg = "横浜市のテニスコートの空き状況です。\n\n"

    reservation_frames.each do |reservation_frame|
      msg += "- #{park_name} #{reservation_frame.to_human}\n"
    end

    msg
  end
end
