# frozen_string_literal: true

require Rails.root.join("domain/pages/yokohama/facility_selection_page")

RSpec.describe Yokohama::FacilitySelectionPage, type: :feature do
  describe "#click_park" do
    subject(:click_park) do
      Yokohama::TopPage.open
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park(park_name)
    end

    context "1ページ目の公園の場合" do
      let(:park_name) { "三ツ沢公園" }

      it "室場分類選択ページに遷移する" do
        click_park
        expect(page).to have_content "室場分類選択"
      end

      it "Yokohama::FieldTypeSelectionPage オブジェクトを返す" do
        expect(click_park).to be_a(Yokohama::FieldTypeSelectionPage)
      end
    end

    context "2ページ目の公園の場合" do
      let(:park_name) { "富岡西公園" }

      it "室場分類選択ページに遷移する" do
        click_park
        expect(page).to have_content "室場分類選択"
      end

      it "Yokohama::FieldTypeSelectionPage オブジェクトを返す" do
        expect(click_park).to be_a(Yokohama::FieldTypeSelectionPage)
      end
    end

    context "存在しない公園の場合" do
      let(:park_name) { "幻公園" }

      it "ParkNotFoundError を raise する" do
        expect { click_park }.to raise_error(Yokohama::FacilitySelectionPage::ParkNotFoundError)
      end
    end
  end
end
