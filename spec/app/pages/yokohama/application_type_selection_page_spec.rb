# frozen_string_literal: true

RSpec.describe Yokohama::ApplicationTypeSelectionPage, type: :feature do
  describe "#click_tennis_court" do
    subject(:click_tennis_court) do
      Yokohama::TopPage.open
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
    end

    it "施設選択ページに遷移する" do
      click_tennis_court
      expect(page).to have_content "施設選択"
    end

    it "Yokohama::FacilitySelectionPage オブジェクトを返す" do
      expect(click_tennis_court).to be_a(Yokohama::FacilitySelectionPage)
    end
  end
end
