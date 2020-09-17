# frozen_string_literal: true

RSpec.describe Yokohama::TreeEventPath, type: :model do
  describe ".build"

  describe "TreeEventPath attributes" do
    using RSpec::Parameterized::TableSyntax

    let!(:now) { Time.zone.now }
    let!(:timestamp) { now.to_s(:iso8601) }

    where(:organization, :park, :date, :time, :tennis_court, :path_excluding_timestamp) do
      nil | nil | nil | nil | nil | ""
      "yokohama" | nil | nil | nil | nil | "/yokohama"
      "yokohama" | "富岡西公園" | nil | nil | nil | "/yokohama/富岡西公園"
      "yokohama" | "富岡西公園" | "2020-09-13" | nil | nil | "/yokohama/富岡西公園/2020-09-13"
      "yokohama" | "富岡西公園" | "2020-09-13" | "11:00~13:00" | nil | "/yokohama/富岡西公園/2020-09-13/11:00~13:00"
      "yokohama" | "富岡西公園" | "2020-09-13" | "11:00~13:00" | "テニスコート１" | "/yokohama/富岡西公園/2020-09-13/11:00~13:00/テニスコート１"
    end

    before do
      travel_to(now)
    end

    with_them do
      it "#timestamp" do
        path = described_class.new("/#{timestamp}#{path_excluding_timestamp}")
        expect(path.timestamp).to eq timestamp
      end

      it "#organization" do
        path = described_class.new("/#{timestamp}#{path_excluding_timestamp}")
        expect(path.organization).to eq organization
      end

      it "#park" do
        path = described_class.new("/#{timestamp}#{path_excluding_timestamp}")
        expect(path.park).to eq park
      end

      it "#date" do
        path = described_class.new("/#{timestamp}#{path_excluding_timestamp}")
        expect(path.date).to eq date
      end

      it "#time" do
        path = described_class.new("/#{timestamp}#{path_excluding_timestamp}")
        expect(path.time).to eq time
      end

      it "#tennis_court" do
        path = described_class.new("/#{timestamp}#{path_excluding_timestamp}")
        expect(path.tennis_court).to eq tennis_court
      end
    end
  end
end
