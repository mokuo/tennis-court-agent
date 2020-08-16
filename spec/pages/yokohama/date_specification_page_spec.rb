# frozen_string_literal: true

RSpec.describe Yokohama::DateSpecificationPage, type: :feature do
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
end
