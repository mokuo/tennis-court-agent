# frozen_string_literal: true

require Rails.root.join("domain/models/available_date")
require Rails.root.join("domain/models/availability_check_identifier")

RSpec.describe Yokohama::AvailableDatesJob, type: :job do
  describe ".dispatch_jobs" do
    subject(:dispatch_jobs) { described_class.dispatch_jobs(identifier, %w[公園１ 公園２]) }

    let!(:identifier) { AvailabilityCheckIdentifier.build }

    it "ジョブをキューに入れる" do
      dispatch_jobs
      expect(described_class).to have_been_enqueued.with(identifier, "公園１").once
      expect(described_class).to have_been_enqueued.with(identifier, "公園２").once
    end
  end

  describe "#perform" do
    let!(:identifier) { AvailabilityCheckIdentifier.build }

    it "利用可能日を収集する" do
      mock_service = instance_double("MockService")
      expect(mock_service).to receive(:available_dates).with(identifier, "公園１")

      job = described_class.new
      allow(job).to receive(:service).and_return(mock_service)
      job.perform(identifier, "公園１")
    end
  end
end
