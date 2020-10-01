# frozen_string_literal: true

require Rails.root.join("domain/pages/yokohama/base_page")

module Yokohama
  class FacilityTypeSelectionPage < BasePage
    def click_sports
      click_button("スポーツ")
      Yokohama::ApplicationTypeSelectionPage.new
    end
  end
end
