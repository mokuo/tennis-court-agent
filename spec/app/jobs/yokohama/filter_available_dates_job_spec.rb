# frozen_string_literal: true

require Rails.root.join("domain/models/available_date")
require Rails.root.join("domain/models/availability_check_identifier")

class MockYokohamaService
  attr_reader :identifier, :park_name, :available_dates

  def filter_available_dates(identifier, park_name, available_dates)
    @identifier = identifier
    @park_name = park_name
    @available_dates = available_dates
  end
end

RSpec.describe Yokohama::FilterAvailableDatesJob, type: :job do
  describe "#perform" do
    let!(:job) { described_class.new }
    let!(:mock_service) { MockYokohamaService.new }
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:date) { Date.current }

    it "利用可能日を収集する" do
      allow(job).to receive(:service).and_return(mock_service)
      job.perform(identifier, "公園１", [date])

      expect(mock_service).to have_attributes(identifier: identifier, park_name: "公園１")
      expect(mock_service.available_dates.first.to_date).to eq date
    end
  end
end
