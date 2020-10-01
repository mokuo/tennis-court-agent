# frozen_string_literal: true

require Rails.root.join("domain/pages/yokohama/facility_type_selection_page")

RSpec.describe Yokohama::FacilityTypeSelectionPage, type: :feature do
  describe "#click_sports" do
    subject(:click_sports) do
      Yokohama::TopPage.open
                       .click_check_availability
                       .click_sports
    end

    it "申込枠区分選択ページに遷移する" do
      click_sports
      expect(page).to have_content "申込枠区分選択"
    end

    it "Yokohama::ApplicationTypeSelectionPage オブジェクトを返す" do
      expect(click_sports).to be_a(Yokohama::ApplicationTypeSelectionPage)
    end
  end
end
