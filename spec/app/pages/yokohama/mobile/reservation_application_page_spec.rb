# frozen_string_literal: true

RSpec.describe Yokohama::Mobile::ReservationApplicationPage, type: :feature do
  describe "#click_sports" do
    subject(:click_sports) do
      Yokohama::Mobile::TopPage.open
                               .click_check_availability
                               .click_sports
    end

    it "施設一覧が表示されること" do
      click_sports
      expect(page).to have_content "次に施設詳細分類を選択してください。"
    end

    it "自身のオブジェクトを返すこと" do
      expect(click_sports).to be_a(described_class)
    end
  end

  describe "#click_park" do
    subject(:click_park) do
      Yokohama::Mobile::TopPage.open
                               .click_check_availability
                               .click_sports
                               .click_park("新杉田公園")
    end

    it "施設詳細分類が表示されること" do
      click_park
      expect(page).to have_content("テニスコート（公園）")
    end

    it "自身のオブジェクトを返すこと" do
      expect(click_park).to be_a(described_class)
    end
  end

  describe "#click_tennis_court" do
    subject(:click_tennis_court) do
      Yokohama::Mobile::TopPage.open
                               .click_check_availability
                               .click_sports
                               .click_park(park_name)
                               .click_tennis_court
    end

    let!(:park_name) { "新杉田公園" }

    it "公園ページに遷移すること" do
      click_tennis_court
      expect(page).to have_content(park_name)
    end

    it "公園ページのオブジェクトを返すこと" do
      expect(click_tennis_court).to be_a(Yokohama::Mobile::TennisCourtSelectionPage)
    end
  end
end
