# frozen_string_literal: true

require Rails.root.join("domain/services/notification_service")
require Rails.root.join("domain/models/availability_check_identifier")
require Rails.root.join("domain/models/yokohama/reservation_frame")

class ClientMock
  attr_reader :sent_message

  def send(message)
    @sent_message = message
  end
end

RSpec.describe NotificationService do
  describe "#send_availabilities" do
    context "正常系" do
      let!(:reservation_frame_1) do
        Yokohama::ReservationFrame.new(
          {
            park_name: "A公園",
            tennis_court_name: "A公園 テニスコート２",
            start_date_time: Time.zone.local(2020, 8, 22, 13),
            end_date_time: Time.zone.local(2020, 8, 22, 15),
            now: false
          }
        )
      end
      let!(:reservation_frame_2) do
        Yokohama::ReservationFrame.new(
          {
            park_name: "A公園",
            tennis_court_name: "A公園 テニスコート１",
            start_date_time: Time.zone.local(2020, 8, 22, 11),
            end_date_time: Time.zone.local(2020, 8, 22, 13),
            now: true
          }
        )
      end
      let!(:reservation_frames) { [reservation_frame_1, reservation_frame_2] }
      let!(:expected_message) do
        <<~MSG
          横浜市のテニスコートの空き状況です。

          - A公園 テニスコート１ 2020/08/22（土） 11:00~13:00 今すぐ予約可能
          - A公園 テニスコート２ 2020/08/22（土） 13:00~15:00 翌日７時に予約可能
        MSG
      end

      it "Notification を保存する" do
        client_mock = ClientMock.new
        notification_service = described_class.new(client_mock)
        expect do
          notification_service.send_availabilities("横浜市", reservation_frames)
        end.to change(Notification, :count).from(0).to(1)
      end

      it "テニスコートの空いている予約枠を通知する" do
        client_mock = ClientMock.new
        notification_service = described_class.new(client_mock)
        notification_service.send_availabilities("横浜市", reservation_frames)
        expect(client_mock.sent_message).to eq expected_message
      end
    end

    context "空いている予約枠がない時" do
      let!(:expected_message) { "横浜市のテニスコートの空き予約枠はありませんでした。" }

      it "Notification を保存する" do
        client_mock = ClientMock.new
        notification_service = described_class.new(client_mock)
        expect do
          notification_service.send_availabilities("横浜市", [])
        end.to change(Notification, :count).from(0).to(1)
      end

      it "空き枠がないことを通知する" do
        client_mock = ClientMock.new
        notification_service = described_class.new(client_mock)
        notification_service.send_availabilities("横浜市", [])
        expect(client_mock.sent_message).to eq expected_message
      end
    end
  end

  describe "#send_message" do
    it "メッセージを送信する" do
      client_mock = ClientMock.new
      notification_service = described_class.new(client_mock)
      notification_service.send_message("テストメッセージ")
      expect(client_mock.sent_message).to eq "テストメッセージ"
    end
  end
end
