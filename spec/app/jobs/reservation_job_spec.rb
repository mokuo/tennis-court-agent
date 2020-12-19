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
  subject(:perform) { job.perform(rf.to_hash) }

  let!(:reservation_frame) { create(:reservation_frame) }
  let!(:rf) { reservation_frame.to_domain_model }
  let!(:job) { described_class.new }

  describe "#perform" do
    before do
      allow(job).to receive(:service).and_return(yokohama_service_mock)
    end

    context "予約に成功する場合" do
      let!(:yokohama_service_mock) { YokohamaServiceMock.new(true) }

      it "予約処理を実行する" do
        perform

        expect(yokohama_service_mock.reservation_frame.eql?(rf)).to be true
      end

      it "予約枠の状態を予約済みにする" do
        perform

        expect(reservation_frame.reload.state).to eq "reserved"
      end
    end

    context "予約に失敗する場合" do
      let!(:yokohama_service_mock) { YokohamaServiceMock.new(false) }

      it "予約処理を実行する" do
        perform

        expect(yokohama_service_mock.reservation_frame.eql?(rf)).to be true
      end

      it "予約枠の状態を失敗にする" do
        perform

        expect(reservation_frame.reload.state).to eq "failed"
      end
    end
  end
end
