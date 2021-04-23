# frozen_string_literal: true

require Rails.root.join("domain/services/yokohama/scraping_service")

RSpec.describe Yokohama::Mobile::LoginPage, type: :feature do
  describe "#login" do
    subject(:login) do
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
        .click_reservation_frame(reservation_frame)
        .click_login
        .login
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
    it "メッセージページかエラーページが表示されること" do
      next_page = login

      if next_page.error_page?
        expect(page).to have_content("選択した枠はキャンセル枠のため、現在予約できません。")
      else
        expect(page).to have_content "施設からの"
        expect(page).to have_content "ﾒｯｾｰｼﾞ"
      end
    end
    # rubocop:enable RSpec/MultipleExpectations

    it "メッセージページのオブジェクトを返すこと" do
      expect(login).to be_a(Yokohama::Mobile::MessagePage)
    end
  end
end
