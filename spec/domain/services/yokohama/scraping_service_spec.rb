# frozen_string_literal: true

require Rails.root.join("domain/services/yokohama/scraping_service")
require Rails.root.join("domain/models/available_date")

RSpec.describe Yokohama::ScrapingService do
  describe "#available_dates" do
    subject(:available_dates) { described_class.new.available_dates("三ツ沢公園") }

    it "AvailableDate の配列を返す" do
      expect(available_dates).to all(be_a(AvailableDate))
    end
  end

  describe "#reservation_frames" do
    subject(:reservation_frames) do
      # NOTE: 最初の日付だと、前日のため予約できない場合が多い
      described_class.new.reservation_frames("三ツ沢公園", available_dates.last.to_date)
    end

    let!(:available_dates) { described_class.new.available_dates("三ツ沢公園") }

    it "Yokohama::ReservationFrame の配列を返す" do
      expect(reservation_frames).to all be_a(Yokohama::ReservationFrame)
    end

    it "公園名も含まれている" do
      expect(reservation_frames.first.park_name).to eq "三ツ沢公園"
    end
  end

  describe "#reservation_status" do
    subject(:reservation_status) { described_class.new.reservation_status("三ツ沢公園", reservation_frame) }

    let!(:available_dates) { described_class.new.available_dates("三ツ沢公園") }
    let!(:reservation_frames) do
      # NOTE: 最初の日付だと、前日のため予約できない場合が多い
      described_class.new.reservation_frames("三ツ沢公園", available_dates.last.to_date)
    end
    let!(:reservation_frame) { reservation_frames.first }

    it { is_expected.to be(true).or be(false) }
  end
end
