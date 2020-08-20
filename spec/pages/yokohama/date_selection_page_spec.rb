# frozen_string_literal: true

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

    it "利用可能な日付を全て取得する" do
      expect(available_dates.size).to be > 0
    end

    it "Date 型の配列を返す" do
      expect(available_dates).to all(be_a(Date))
    end
  end

  describe "#click_next_month" do
    subject(:click_next_month) { date_specification_page.click_next_month }

    let!(:date_specification_page) do
      Yokohama::TopPage.open
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park("三ツ沢公園")
                       .click_tennis_court
    end

    it "翌月の表示日指定ページか、エラーページに遷移する" do
      page_title = click_next_month.error_page? ? "エラー" : "表示日指定"
      expect(page).to have_content page_title
    end

    it "自身のオブジェクトを返す" do
      expect(click_next_month).to be_a(described_class)
    end

    it "新しいオブジェクトを返す" do
      expect(click_next_month).not_to be date_specification_page
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
                       .click_date(available_date)
    end

    let!(:available_date) do
      current_month_page = Yokohama::TopPage.open
                                            .login
                                            .click_check_availability
                                            .click_sports
                                            .click_tennis_court
                                            .click_park("三ツ沢公園")
                                            .click_tennis_court

      available_dates = current_month_page.available_dates
      next_month_page = current_month_page.click_next_month

      # NOTE: 最初の日付だと、前日のため予約できない場合が多い
      next_month_page.error_page? ? available_dates.last : next_month_page.available_dates.last
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
