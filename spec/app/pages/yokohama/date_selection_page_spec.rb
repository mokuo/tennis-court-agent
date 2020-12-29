# frozen_string_literal: true

require Rails.root.join("domain/models/available_date")
require Rails.root.join("domain/services/yokohama/scraping_service")

RSpec.describe Yokohama::DateSelectionPage, type: :feature do
  describe "#available_dates" do
    subject(:available_dates) do
      Yokohama::TopPage.open
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park("三ツ沢公園")
                       .click_tennis_court
                       .available_dates
    end

    it "AvailableDate の配列を返す" do
      expect(available_dates).to all(be_a(AvailableDate))
    end
  end

  describe "#click_date" do
    subject(:click_date) do
      Yokohama::TopPage.open
                       .login
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park("三ツ沢公園")
                       .click_tennis_court
                       .click_date(available_date.to_date)
    end

    let!(:available_date) do
      available_dates = Yokohama::ScrapingService.new.available_dates("三ツ沢公園")
      # NOTE: 最初の日付だと、前日のため予約できない場合が多い
      available_dates.last
    end

    it "予約枠指定ページに遷移する" do
      click_date
      expect(page).to have_content "予約枠指定"
    end

    it "Yokohama::ReservationFrameSelectionPage オブジェクトを返す" do
      expect(click_date).to be_a(Yokohama::ReservationFrameSelectionPage)
    end
  end
end
