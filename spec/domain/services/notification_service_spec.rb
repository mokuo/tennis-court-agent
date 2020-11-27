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
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    context "正常系" do
      let!(:reservation_frame_1) do
        Yokohama::ReservationFrame.new(
          {
            park_name: "公園名１",
            tennis_court_name: "公園名１ テニスコート２",
            start_date_time: Time.zone.local(2020, 8, 22, 13),
            end_date_time: Time.zone.local(2020, 8, 22, 15),
            now: false
          }
        )
      end
      let!(:reservation_frame_2) do
        Yokohama::ReservationFrame.new(
          {
            park_name: "公園名１",
            tennis_court_name: "公園名１ テニスコート１",
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

          - 公園名１ テニスコート１ 2020/08/22（土） 11:00~13:00 今すぐ予約可能
          - 公園名１ テニスコート２ 2020/08/22（土） 13:00~15:00 翌日７時に予約可能
        MSG
      end

      it "Notification を保存する" do
        client_mock = ClientMock.new
        notification_service = described_class.new(client_mock)
        expect do
          notification_service.send_availabilities(identifier, "横浜市", reservation_frames)
        end.to change(Notification, :count).from(0).to(1)
      end

      it "テニスコートの空いている予約枠を通知する" do
        client_mock = ClientMock.new
        notification_service = described_class.new(client_mock)
        notification_service.send_availabilities(identifier, "横浜市", reservation_frames)
        expect(client_mock.sent_message).to eq expected_message
      end
    end

    context "空いている予約枠がない時" do
      let!(:expected_message) { "横浜市のテニスコートの空き予約枠はありませんでした。" }

      it "Notification を保存する" do
        client_mock = ClientMock.new
        notification_service = described_class.new(client_mock)
        expect do
          notification_service.send_availabilities(identifier, "横浜市", [])
        end.to change(Notification, :count).from(0).to(1)
      end

      it "空き枠がないことを通知する" do
        client_mock = ClientMock.new
        notification_service = described_class.new(client_mock)
        notification_service.send_availabilities(identifier, "横浜市", [])
        expect(client_mock.sent_message).to eq expected_message
      end
    end

    context "通知済みの時" do
      let!(:reservation_frame) do
        Yokohama::ReservationFrame.new(
          {
            park_name: "公園名１",
            tennis_court_name: "公園名１ テニスコート２",
            start_date_time: Time.zone.local(2020, 8, 22, 13),
            end_date_time: Time.zone.local(2020, 8, 22, 15),
            now: false
          }
        )
      end
      let!(:reservation_frames) { [reservation_frame] }

      before do
        Notification.create!(availability_check_identifier: identifier)
      end

      it "ログを吐く" do
        error_message = <<~MSG
          #<ActiveRecord::RecordNotUnique: PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "index_notifications_on_availability_check_identifier"
          DETAIL:  Key (availability_check_identifier)=(#{identifier}) already exists.
          >
        MSG
        expect(Rails.logger).to receive(:info).with(error_message.chomp)

        client_mock = ClientMock.new
        notification_service = described_class.new(client_mock)
        notification_service.send_availabilities(identifier, "横浜市", reservation_frames)
      end

      it "通知しない" do
        client_mock = ClientMock.new
        notification_service = described_class.new(client_mock)
        notification_service.send_availabilities(identifier, "横浜市", reservation_frames)
        expect(client_mock.sent_message).to be_nil
      end
    end
  end

  describe "private" do
    describe "#sort_reservation_frames" do
      let!(:reservation_frame_1) do
        Yokohama::ReservationFrame.new(
          {
            park_name: "公園名１",
            tennis_court_name: "公園名１ テニスコート１",
            start_date_time: Time.zone.local(2020, 8, 22, 13),
            end_date_time: Time.zone.local(2020, 8, 22, 15),
            now: true
          }
        )
      end
      let!(:reservation_frame_2) do
        Yokohama::ReservationFrame.new(
          {
            park_name: "公園名２",
            tennis_court_name: "公園名２ テニスコート１",
            start_date_time: Time.zone.local(2020, 8, 22, 11),
            end_date_time: Time.zone.local(2020, 8, 22, 13),
            now: true
          }
        )
      end
      let!(:reservation_frame_3) do
        Yokohama::ReservationFrame.new(
          {
            park_name: "公園名１",
            tennis_court_name: "公園名１ テニスコート２",
            start_date_time: Time.zone.local(2020, 8, 22, 11),
            end_date_time: Time.zone.local(2020, 8, 22, 13),
            now: true
          }
        )
      end
      let!(:reservation_frame_4) do
        Yokohama::ReservationFrame.new(
          {
            park_name: "公園名１",
            tennis_court_name: "公園名１ テニスコート１",
            start_date_time: Time.zone.local(2020, 8, 22, 11),
            end_date_time: Time.zone.local(2020, 8, 22, 13),
            now: true
          }
        )
      end
      let!(:reservation_frames) do
        [
          reservation_frame_1,
          reservation_frame_2,
          reservation_frame_3,
          reservation_frame_4
        ]
      end

      # rubocop:disable RSpec/MultipleExpectations
      it "park_name, tennis_court_name, start_date_time の順に並び替える" do
        result = described_class.new.send(:sort_reservation_frames, reservation_frames)
        expect(result[0].eql?(reservation_frame_4)).to be true
        expect(result[1].eql?(reservation_frame_1)).to be true
        expect(result[2].eql?(reservation_frame_3)).to be true
        expect(result[3].eql?(reservation_frame_2)).to be true
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end
end
