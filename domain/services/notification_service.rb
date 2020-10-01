# frozen_string_literal: true

class NotificationService
  def initialize(client = SlackClient.new)
    @client = client
  end

  def send_availabilities(reservation_frames)
    message = build_message(reservation_frames)
    client.send(message)
  end

  private

  attr_reader :client

  def build_message(reservation_frames)
    r = reservation_frames.first

    msg = "#{r.organization_name_ja}のテニスコートの空き状況です。\n\n"

    reservation_frames.each do |reservation_frame|
      msg += "- #{reservation_frame.to_human}\n"
    end

    msg
  end
end
