# frozen_string_literal: true

require Rails.root.join("domain/services/yokohama/scraping_service")

RSpec.describe Yokohama::Mobile::ReservationFrameSelectionPage, type: :feature do
  describe "#click_reservation_frame" do
    subject(:click_reservation_frame) do
      Yokohama::Mobile::TopPage
        .open
        .click_check_availability
        .click_sports
        .click_park(park_name)
        .click_tennis_court
        .select_date(available_date.to_date)
        .select_tennis_court(reservation_frame.plain_tennis_court_name)
        .click_next
        .click_first_date
        .click_reservation_frame(reservation_frame)
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

    it "予約枠が選択状態になること" do
      reservation_frame_selection_page = click_reservation_frame

      expect(
        reservation_frame_selection_page.send(:reservation_frame_clicked?, reservation_frame)
      ).to be true
      expect(page).to have_button("ログイン") # NOTE: 予約枠を選択すると「ログイン」ボタンが現れる
    end

    it "自身のオブジェクトを返す" do
      expect(click_reservation_frame).to be_a(described_class)
    end
  end

  describe "#click_login" do
    subject(:click_login) do
      Yokohama::Mobile::TopPage
        .open
        .click_check_availability
        .click_sports
        .click_park(park_name)
        .click_tennis_court
        .select_date(available_date.to_date)
        .select_tennis_court(reservation_frame.plain_tennis_court_name)
        .click_next
        .click_first_date
        .click_reservation_frame(reservation_frame)
        .click_login
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

    it "ログイン画面に遷移すること" do
      click_login

      expect(page).to have_content("◇◆ﾛｸﾞｲﾝ◆◇")
    end

    it "ログインページのオブジェクトを返す" do
      expect(click_login).to be_a(Yokohama::Mobile::LoginPage)
    end
  end
end
