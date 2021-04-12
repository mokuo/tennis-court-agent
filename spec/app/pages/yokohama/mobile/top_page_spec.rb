# frozen_string_literal: true

RSpec.describe Yokohama::Mobile::TopPage, type: :feature do
  describe ".open" do
    subject(:open) { described_class.open }

    it "トップページが表示されること" do
      open
      expect(page).to have_content "【携帯電話サイト】"
    end

    it "自身のオブジェクトを返すこと" do
      expect(open).to be_a(described_class)
    end
  end

  describe "#click_check_availability" do
    subject(:click_check_availability) do
      described_class.open
                     .click_check_availability
    end

    it "予約申込ページに遷移すること" do
      click_check_availability
      expect(page).to have_content "予約申込"
    end

    it "予約申込ページのオブジェクトを返すこと" do
      expect(click_check_availability).to be_a(Yokohama::Mobile::ReservationApplicationPage)
    end
  end
end
