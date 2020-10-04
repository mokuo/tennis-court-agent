# frozen_string_literal: true

module Yokohama
  class ApplicationTypeSelectionPage < BasePage
    def click_tennis_court
      click_button("テニスコート")
      Yokohama::FacilitySelectionPage.new
    end
  end
end
