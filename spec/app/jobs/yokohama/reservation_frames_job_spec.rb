# frozen_string_literal: true

require Rails.root.join("domain/models/availability_check_identifier")

class MockService
  attr_reader :identifier, :park_name, :available_date

  def reservation_frames(identifier, park_name, available_date)
    @identifier = identifier
    @park_name = park_name
    @available_date = available_date
  end
end

RSpec.describe Yokohama::ReservationFramesJob, type: :job do
  describe ".dispatch_jobs" do
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:today) { Date.current }
    let!(:tomorrow) { Date.tomorrow }

    it "ジョブをキューに入れる" do
      described_class.dispatch_jobs(identifier, "公園１", [today, tomorrow])
      expect(described_class).to have_been_enqueued.with(identifier, "公園１", today).once
      expect(described_class).to have_been_enqueued.with(identifier, "公園１", tomorrow).once
    end
  end

  describe "#perform" do
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:date) { Date.current }

    it "予約枠を取得する" do
      mock_service = MockService.new
      job = described_class.new
      allow(job).to receive(:service).and_return(mock_service)
      job.perform(identifier, "公園１", date)

      expect(mock_service).to have_attributes(identifier: identifier, park_name: "公園１")
      expect(mock_service.available_date.eql?(AvailableDate.new(date))).to be true
    end
  end
end
