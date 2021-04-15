# frozen_string_literal: true

require Rails.root.join("domain/models/available_date")
require Rails.root.join("domain/services/yokohama/scraping_service")

# NOTE: 曜日を日本語に変換する https://docs.ruby-lang.org/ja/latest/method/Time/i/strftime.html
def ja_wday(num)
  weeks = %w[日曜日 月曜日 火曜日 水曜日 木曜日 金曜日 土曜日]
  weeks[num]
end

RSpec.describe Yokohama::Mobile::DateSelectionPage, type: :feature do
  describe "#click_date" do
    subject(:click_first_date) do
      Yokohama::Mobile::TopPage
        .open
        .click_check_availability
        .click_sports
        .click_park(park_name)
        .click_tennis_court
        .select_date(available_date.to_date)
        .select_tennis_court(reservation_frame)
        .click_next
        .click_first_date
    end

    let!(:park_name) { "三ツ沢公園" }
    let!(:available_date) do
      available_dates = Yokohama::ScrapingService.new.available_dates(park_name)
      # NOTE: 最初の日付だと、前日のため予約できない場合が多い
      available_dates.last
    end
    let!(:reservation_frame) do
      reservation_frames = Yokohama::ScrapingService.new.reservation_frames(park_name, available_date.to_date)
      reservation_frames.last
    end

    # rubocop:disable RSpec/MultipleExpectations
    it "予約枠選択ページに遷移すること" do
      click_first_date

      date = available_date.to_date
      expect(page).to have_content(park_name)
      expect(page).to have_content(reservation_frame.plain_tennis_court_name)
      expect(page).to have_content("#{date.year}年#{date.month}月#{date.day}日(#{ja_wday(date.wday)})")
    end
    # rubocop:enable RSpec/MultipleExpectations

    it "予約枠選択ページのオブジェクトを返すこと" do
      expect(click_first_date).to be_a(Yokohama::Mobile::ReservationFrameSelectionPage)
    end
  end
end
