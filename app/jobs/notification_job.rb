# frozen_string_literal: true

class NotificationJob < Gush::Job
  def perform
    reservation_frames = payloads.map { |p| p[:output][:reservation_frame] }
    message = build_message(params[:park_name], reservation_frames)
    notification.send(message)
  end

  private

  def notification
    params[:notification] || Notification.new
  end

  def build_message(park_name, reservation_frames)
    msg = "横浜市のテニスコートの空き状況です。\n\n"

    reservation_frames.each do |reservation_frame|
      msg += "- #{park_name} #{reservation_frame.to_human}\n"
    end

    msg
  end
end