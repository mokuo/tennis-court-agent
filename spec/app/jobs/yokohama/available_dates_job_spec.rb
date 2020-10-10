# frozen_string_literal: true

require Rails.root.join("domain/models/available_date")
require Rails.root.join("domain/models/availability_check_identifier")

class MockEvent
  attr_reader :availability_check_identifier, :park_name, :available_dates, :published

  def initialize(availability_check_identifier:, park_name:, available_dates:)
    @availability_check_identifier = availability_check_identifier
    @park_name = park_name
    @available_dates = available_dates
    @published = false
  end

  def publish!
    @published = true
    self
  end
end

RSpec.describe Yokohama::AvailableDatesJob, type: :job do
  describe ".dispatch_jobs" do
    subject(:dispatch_jobs) { described_class.dispatch_jobs(identifier, %w[公園１ 公園２]) }

    let!(:identifier) { AvailabilityCheckIdentifier.build }

    before { ActiveJob::Base.queue_adapter = :test }

    it "ジョブをキューに入れる" do
      dispatch_jobs
      expect(described_class).to have_been_enqueued.with(identifier.to_s, "公園１").once
      expect(described_class).to have_been_enqueued.with(identifier.to_s, "公園２").once
    end
  end

  describe "#perform" do
    let!(:now) { Date.current }
    let!(:available_date) { AvailableDate.new(now) }
    let!(:mock_service) { instance_double("mock_scraping_service") }
    let!(:identifier) { AvailabilityCheckIdentifier.build }

    it "利用可能日を取得して、ドメインイベントを発行する" do
      expect(mock_service).to receive(:available_dates).with("公園１").and_return([available_date])
      published_event = described_class.perform_now(identifier.to_s, "公園１", mock_service, MockEvent)

      expect(published_event).to have_attributes(
        availability_check_identifier: identifier.to_s,
        park_name: "公園１",
        available_dates: [available_date],
        published: true
      )
    end
  end
end
