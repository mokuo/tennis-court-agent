# frozen_string_literal: true

require Rails.root.join("domain/services/notification_service")
require Rails.root.join("domain/models/yokohama/reservation_frame")

class ClientMock
  attr_reader :message_sent

  def send(message)
    @message_sent = message
  end
end

RSpec.describe NotificationService do
  # TODO: ReservationStatusChecked イベントの attributes から取る？
  xdescribe "#send_availabilities" do
    let!(:reservation_frame_1) do
      Yokohama::ReservationFrame.new(
        {
          tennis_court_name: "テニスコート１",
          start_date_time: Time.zone.local(2020, 8, 22, 11),
          end_date_time: Time.zone.local(2020, 8, 22, 13),
          now: true
        }
      )
    end
    let!(:reservation_frame_2) do
      Yokohama::ReservationFrame.new(
        {
          tennis_court_name: "テニスコート２",
          start_date_time: Time.zone.local(2020, 8, 22, 13),
          end_date_time: Time.zone.local(2020, 8, 22, 15),
          now: false
        }
      )
    end
    let!(:reservation_frames) { [reservation_frame_1, reservation_frame_2] }
    let!(:expected_message) do
      <<~MSG
        横浜市のテニスコートの空き状況です。

        - 富岡西公園 テニスコート１ 2020/08/22（土） 11:00~13:00 今すぐ予約可能
        - 富岡西公園 テニスコート２ 2020/08/22（土） 13:00~15:00 翌日７時に予約可能
      MSG
    end

    it "テニスコートの空いている予約枠を通知する" do
      client_mock = ClientMock.new
      notification_service = described_class.new(client_mock)
      notification_service.send_availabilities("横浜市", "富岡西公園", reservation_frames)
      expect(client_mock.message_sent).to eq expected_message
    end
  end
end
