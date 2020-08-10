# frozen_string_literal: true

RSpec.describe Yokohama::FieldTypeSelectionPage, type: :feature do
  describe "#click_tennis_court" do
    subject(:click_tennis_court) do
      Yokohama::TopPage.new
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park("三ツ沢公園")
                       .click_tennis_court
    end

    it "表示日指定ページに遷移する" do
      click_tennis_court
      expect(page).to have_content "表示日指定"
    end

    it "Yokohama::DateSpecificationPage オブジェクトを返す" do
      expect(click_tennis_court).to be_a(Yokohama::DateSpecificationPage)
    end
  end
end
