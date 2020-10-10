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
      Yokohama::TopPage.open
                       .login
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park("三ツ沢公園")
                       .click_tennis_court
                       .click_date(available_dates.last.to_date) # NOTE: 最初の日付だと、前日のため予約できない場合が多い
                       .reservation_frames
    end

    let!(:available_dates) do
      Yokohama::TopPage.open
                       .login
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park("三ツ沢公園")
                       .click_tennis_court
                       .available_dates
    end

    it "Yokohama::ReservationFrame の配列を返す" do
      expect(reservation_frames).to all be_a(Yokohama::ReservationFrame)
    end
  end

  describe "#reservation_status" do
    subject(:reservation_status) { described_class.new.reservation_status("三ツ沢公園", reservation_frame) }

    let!(:available_dates) do
      Yokohama::TopPage.open
                       .login
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park("三ツ沢公園")
                       .click_tennis_court
                       .available_dates
    end
    let!(:reservation_frame_selection_page) do
      Yokohama::TopPage.open
                       .login
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park("三ツ沢公園")
                       .click_tennis_court
                       .click_date(available_dates.last.to_date) # NOTE: 最初の日付だと、前日のため予約できない場合が多い
    end
    let!(:reservation_frame) { reservation_frame_selection_page.reservation_frames.first }

    it { is_expected.to be(true).or be(false) }
  end
end
