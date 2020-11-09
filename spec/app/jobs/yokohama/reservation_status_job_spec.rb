# frozen_string_literal: true

require Rails.root.join("domain/models/availability_check_identifier")
require Rails.root.join("domain/models/yokohama/reservation_frame")

class MockService
  attr_reader :identifier, :park_name, :reservation_frame

  def reservation_status(identifier, park_name, reservation_frame)
    @identifier = identifier
    @park_name = park_name
    @reservation_frame = reservation_frame
  end
end

RSpec.describe Yokohama::ReservationStatusJob, type: :job do
  describe ".dispatch_jobs" do
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:now) { Time.current }
    let!(:reservation_frame_1) do
      Yokohama::ReservationFrame.new(
        park_name: "公園１",
        tennis_court_name: "テニスコート１",
        start_date_time: now.next_day,
        end_date_time: now.next_day.change(hour: now.hour + 2)
      )
    end
    let!(:reservation_frame_2) do
      Yokohama::ReservationFrame.new(
        park_name: "公園１",
        tennis_court_name: "テニスコート２",
        start_date_time: now.next_day,
        end_date_time: now.next_day.change(hour: now.hour + 2)
      )
    end

    it "ジョブをキューに入れる" do
      described_class.dispatch_jobs(identifier, "公園１", [reservation_frame_1, reservation_frame_2])
      expect(described_class).to have_been_enqueued.with(identifier, "公園１", reservation_frame_1.to_hash).once
      expect(described_class).to have_been_enqueued.with(identifier, "公園１", reservation_frame_2.to_hash).once
    end
  end

  describe "#perform" do
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:now) { Time.current }
    let!(:reservation_frame) do
      Yokohama::ReservationFrame.new(
        park_name: "公園１",
        tennis_court_name: "テニスコート１",
        start_date_time: now.next_day,
        end_date_time: now.next_day.change(hour: now.hour + 2)
      )
    end

    it "予約枠を取得する" do
      mock_service = MockService.new
      job = described_class.new
      allow(job).to receive(:service).and_return(mock_service)
      job.perform(identifier, "公園１", reservation_frame.to_hash)

      expect(mock_service).to have_attributes(identifier: identifier, park_name: "公園１")
      expect(mock_service.reservation_frame.eql?(reservation_frame)).to be true
    end
  end
end
