# frozen_string_literal: true

require Rails.root.join("domain/services/reservation_frames_service")

class NotificationService
  def initialize(client = SlackClient.new)
    @client = client
  end

  def send_availabilities(identifier, organization_name, reservation_frames)
    Notification.create!(availability_check_identifier: identifier)
    message = build_message(organization_name, reservation_frames)
    client.send(message)
  rescue ActiveRecord::RecordNotUnique => e
    Rails.logger.info(e.inspect)
  end

  def send_message(message)
    client.send(message)
  end

  private

  attr_reader :client

  def build_message(organization_name, reservation_frames)
    return "#{organization_name}のテニスコートの空き予約枠はありませんでした。" if reservation_frames.blank?

    msg = "#{organization_name}のテニスコートの空き状況です。\n\n"

    rfs = sort_reservation_frames(reservation_frames)
    rfs.each do |reservation_frame|
      msg += "- #{reservation_frame.to_human}\n"
    end

    msg
  end

  def sort_reservation_frames(reservation_frames)
    ReservationFramesService.new.sort(reservation_frames)
  end
end
