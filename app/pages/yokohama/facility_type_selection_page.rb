# frozen_string_literal: true

module Yokohama
  class FacilityTypeSelectionPage < BasePage
    def click_sports
      click_button("スポーツ")
      Yokohama::ApplicationTypeSelectionPage.new
    end
  end
end
