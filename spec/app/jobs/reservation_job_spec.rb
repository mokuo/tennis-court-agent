# frozen_string_literal: true

require Rails.root.join("domain/models/yokohama/reservation_frame")

class YokohamaServiceMock
  attr_reader :reservation_frame, :waiting

  def initialize
    @reservation_frame = nil
    @waiting = nil
  end

  def reserve(reservation_frame, waiting:)
    @reservation_frame = reservation_frame
    @waiting = waiting
  end
end

RSpec.describe ReservationJob, type: :job do
  let!(:reservation_frame) { create(:reservation_frame) }
  let!(:rf) { reservation_frame.to_domain_model }
  let!(:job) { described_class.new }
  let!(:yokohama_service_mock) { YokohamaServiceMock.new }

  describe "#perform" do
    before do
      allow(job).to receive(:yokohama_service).and_return(yokohama_service_mock)
    end

    it "予約処理を実行する" do
      job.perform(rf.to_hash, waiting: false)

      expect(yokohama_service_mock.reservation_frame.eql?(rf)).to be true
      expect(yokohama_service_mock.waiting).to be false
    end
  end
end
