# frozen_string_literal: true

require Rails.root.join("domain/pages/yokohama/top_page")

RSpec.describe Yokohama::TopPage, type: :feature do
  describe ".open" do
    subject(:open) { described_class.open }

    it "トップページが表示されること" do
      open
      expect(page).to have_content "こんにちはゲストさん。ログインしてください。"
    end

    it "自身のオブジェクトを返す" do
      expect(open).to be_a described_class
    end
  end

  describe "#click_check_availability" do
    subject(:click_check_availability) { described_class.open.click_check_availability }

    it "施設分類選択ページに遷移すること" do
      click_check_availability
      expect(page).to have_content "施設分類選択"
    end

    it "Yokohama::FacilityTypeSelectionPage オブジェクトを返すこと" do
      expect(click_check_availability).to be_a(Yokohama::FacilityTypeSelectionPage)
    end
  end

  describe "#login" do
    subject(:login) { top_page.login }

    let!(:top_page) { described_class.open }

    context "未ログインの場合" do
      it "ログインする" do
        expect { login }.to change(top_page, :logged_in?).from(false).to(true)
      end

      it "自身のオブジェクトを返す" do
        expect(login).to be_a described_class
      end

      it "新しい TopPage オブジェクトを返す" do
        expect(login).not_to be top_page
      end
    end

    context "ログイン済みの場合" do
      before { top_page.login }

      it "ログインしたままである" do
        expect { login }.not_to change(top_page, :logged_in?)
      end

      it "自身のオブジェクトを返す" do
        expect(login).to be_a described_class
      end

      it "新しい TopPage オブジェクトを返す" do
        expect(login).not_to be top_page
      end
    end
  end
end
