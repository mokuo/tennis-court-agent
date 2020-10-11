# frozen_string_literal: true

require Rails.root.join("domain/models/available_date")
require Rails.root.join("domain/models/availability_check_identifier")

RSpec.describe YokohamaService, type: :job do
  describe "#available_dates" do
    let!(:mock_scraping_service) { instance_double("mock_scraping_service") }
    let!(:available_date) { AvailableDate.new(Date.current) }
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:now) { Time.current }
    let!(:expected_event_hash) do
      {
        availability_check_identifier: identifier,
        park_name: "公園１",
        available_dates: [available_date.to_date],
        name: "Yokohama::AvailableDatesFound",
        published_at: now
      }
    end

    before { travel_to(now) }

    it "利用可能日を取得するし、ドメインイベントを永続化する" do
      expect(mock_scraping_service).to receive(:available_dates).with("公園１").and_return([available_date])

      yokohama_service = described_class.new(mock_scraping_service)
      yokohama_service.available_dates(identifier, "公園１")

      expect(PersistEventJob).to have_been_enqueued.with(expected_event_hash)
    end

    xit "次のジョブをキューに入れる" do
    end
  end
end
