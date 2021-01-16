# frozen_string_literal: true

require Rails.root.join("domain/models/yokohama/reservation_frame")

class YokohamaServiceMock
  attr_reader :result, :reservation_frame

  def initialize(result)
    @result = result
    @reservation_frame = nil
  end

  def reserve(reservation_frame)
    @reservation_frame = reservation_frame
    result
  end
end

RSpec.describe ReservationJob, type: :job do
  subject(:perform) { job.perform(rf.to_hash, 1) }

  let!(:reservation_frame) { create(:reservation_frame) }
  let!(:rf) { reservation_frame.to_domain_model }
  let!(:job) { described_class.new }
  let!(:notification_service_mock) { instance_double("NotificationService") }

  describe "#perform" do
    before do
      allow(job).to receive(:service).and_return(yokohama_service_mock)
      allow(job).to receive(:notification_service).and_return(notification_service_mock)
    end

    context "予約に成功する場合" do
      let!(:yokohama_service_mock) { YokohamaServiceMock.new(true) }

      it "予約処理を実行する" do
        allow(notification_service_mock).to receive(:send_message)
        perform

        expect(yokohama_service_mock.reservation_frame.eql?(rf)).to be true
      end

      it "予約枠の状態を予約済みにする" do
        allow(notification_service_mock).to receive(:send_message)
        perform

        expect(reservation_frame.reload.state).to eq "reserved"
      end

      it "開始と成功の通知をする" do
        expect(notification_service_mock).to receive(:send_message).with("`#{rf.to_human}`の予約を開始します。(1)")
        expect(notification_service_mock).to receive(:send_message).with("`#{rf.to_human}`の予約に成功しました！(1)")
        perform
      end
    end

    context "予約に失敗する場合" do
      let!(:yokohama_service_mock) { YokohamaServiceMock.new(false) }

      it "予約処理を実行する" do
        allow(notification_service_mock).to receive(:send_message)
        perform

        expect(yokohama_service_mock.reservation_frame.eql?(rf)).to be true
      end

      it "予約枠の状態を失敗にする" do
        allow(notification_service_mock).to receive(:send_message)
        perform

        expect(reservation_frame.reload.state).to eq "failed"
      end

      it "開始と失敗の通知をする" do
        expect(notification_service_mock).to receive(:send_message).with("`#{rf.to_human}`の予約を開始します。(1)")
        expect(notification_service_mock).to receive(:send_message).with("`#{rf.to_human}`の予約に失敗しました。(1)")
        perform
      end
    end
  end
end
