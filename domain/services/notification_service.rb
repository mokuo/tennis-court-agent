# frozen_string_literal: true

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

  private

  attr_reader :client

  def build_message(organization_name, reservation_frames)
    msg = "#{organization_name}のテニスコートの空き状況です。\n\n"

    rfs = sort_reservation_frames(reservation_frames)
    rfs.each do |reservation_frame|
      msg += "- #{reservation_frame.to_human}\n"
    end

    msg
  end

  def sort_reservation_frames(reservation_frames)
    rfs = reservation_frames.sort_by(&:start_date_time)
    rfs = rfs.sort_by(&:tennis_court_name)
    rfs.sort_by(&:park_name)
  end
end
