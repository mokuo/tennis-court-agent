# frozen_string_literal: true

require Rails.root.join("domain/models/available_date")
require Rails.root.join("domain/models/availability_check_identifier")

RSpec.describe YokohamaService, type: :job do
  describe "#available_dates" do
    subject(:available_dates) { yokohama_service.available_dates(identifier, "公園１") }

    let!(:yokohama_service) { described_class.new(mock_scraping_service) }
    let!(:mock_scraping_service) { instance_double("Yokohama::ScrapingService") }
    let!(:available_date) { AvailableDate.new(Date.current) }
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:now) { Time.current }

    before do
      travel_to(now)
      allow(mock_scraping_service).to receive(:available_dates).and_return([available_date])
    end

    it "利用可能日を取得する" do
      expect(mock_scraping_service).to receive(:available_dates).with("公園１").and_return([available_date])

      available_dates
    end

    it "ドメインイベントを発行し、永続化される" do
      available_dates

      expect(PersistEventJob).to have_been_enqueued.with(
        {
          availability_check_identifier: identifier,
          park_name: "公園１",
          available_dates: [available_date.to_date],
          name: "Yokohama::AvailableDatesFound",
          published_at: now
        }
      )
    end

    it "次のジョブがキューに入る" do
      available_dates

      expect(Yokohama::FilterAvailableDatesJob).to have_been_enqueued.with(identifier, "公園１", [available_date.to_date])
    end
  end

  describe "#filter_available_dates" do
    let!(:holiday) { Date.new(2020, 10, 11) }
    let!(:weekday) { Date.new(2020, 10, 12) }
    let!(:available_dates) { [AvailableDate.new(holiday), AvailableDate.new(weekday)] }
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:now) { Time.current }

    before { travel_to(now) }

    it "利用可能日を休日に絞り、ドメインイベントを発行する" do
      described_class.new.filter_available_dates(identifier, "公園１", available_dates)

      expect(PersistEventJob).to have_been_enqueued.with(
        {
          availability_check_identifier: identifier,
          park_name: "公園１",
          available_dates: [holiday],
          name: "Yokohama::AvailableDatesFiltered",
          published_at: now
        }
      )
    end

    xit "次のジョブがキューに入る" do
    end
  end
end
