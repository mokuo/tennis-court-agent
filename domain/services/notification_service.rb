# frozen_string_literal: true

class NotificationService
  def initialize(client = SlackClient.new)
    @client = client
  end

  def send_availabilities(organization_name, park_name, reservation_frames)
    message = build_message(organization_name, park_name, reservation_frames)
    client.send(message)
  end

  private

  attr_reader :client

  # TODO: ReservationStatusChecked イベントの attributes から取る？
  def build_message(organization_name, park_name, reservation_frames)
    msg = "#{organization_name}のテニスコートの空き状況です。\n\n"

    reservation_frames.each do |reservation_frame|
      msg += "- #{park_name} #{reservation_frame.to_human}\n"
    end

    msg
  end
end
