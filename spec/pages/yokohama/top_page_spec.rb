# frozen_string_literal: true

RSpec.describe Yokohama::TopPage, type: :feature do
  describe ".new" do
    it "トップページが表示されること" do
      described_class.new
      expect(page).to have_content "こんにちはゲストさん。ログインしてください。"
    end
  end

  describe "#click_check_availability" do
    subject(:click_check_availability) { described_class.new.click_check_availability }

    it "施設分類選択ページに遷移すること" do
      click_check_availability
      expect(page).to have_content "施設分類選択"
    end

    it "Yokohama::FacilityTypeSelectionPage オブジェクトを返すこと" do
      expect(click_check_availability).to be_a(Yokohama::FacilityTypeSelectionPage)
    end
  end
end
