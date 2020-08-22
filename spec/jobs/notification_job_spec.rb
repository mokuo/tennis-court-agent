# frozen_string_literal: true

class NotificationMock
  attr_reader :message

  def send(message)
    @message = message
  end
end

RSpec.describe NotificationJob, type: :job do
  describe "#perform" do
    subject(:notify) { job.perform }

    let!(:params) do
      { params: { park_name: "富岡西公園", notification: notification } }
    end
    let!(:job) { described_class.new(params) }
    let!(:notification) { NotificationMock.new }
    let(:reservation_frame1) do
      Yokohama::ReservationFrame.new(
        {
          tennis_court_name: "テニスコート１",
          start_date_time: Time.zone.local(2020, 8, 22, 11),
          end_date_time: Time.zone.local(2020, 8, 22, 13),
          now: true
        }
      )
    end
    let(:reservation_frame2) do
      Yokohama::ReservationFrame.new(
        {
          tennis_court_name: "テニスコート２",
          start_date_time: Time.zone.local(2020, 8, 22, 13),
          end_date_time: Time.zone.local(2020, 8, 22, 15),
          now: false
        }
      )
    end
    let(:expected_message) do
      <<~MSG
        横浜市のテニスコートの空き状況です。

        - 富岡西公園 テニスコート１ 2020/08/22（土） 11:00~13:00 今すぐ予約可能
        - 富岡西公園 テニスコート２ 2020/08/22（土） 13:00~15:00 翌日７時に予約可能
      MSG
    end

    before do
      job.payloads = [
        {
          id: "xxx",
          class: "Yokohama::ReservationStatusCheckJob",
          output: {
            reservation_frame: reservation_frame1
          }
        },
        {
          id: "xxx",
          class: "Yokohama::ReservationStatusCheckJob",
          output: {
            reservation_frame: reservation_frame2
          }
        }
      ]
    end

    it "テニスコートの利用可能な日時を通知する" do
      notify
      expect(notification.message).to eq expected_message
    end
  end
end
