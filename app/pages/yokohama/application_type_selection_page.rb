# frozen_string_literal: true

require Rails.root.join("domain/pages/yokohama/base_page")
require Rails.root.join("domain/pages/yokohama/facility_selection_page")

module Yokohama
  class ApplicationTypeSelectionPage < BasePage
    def click_tennis_court
      click_button("テニスコート")
      Yokohama::FacilitySelectionPage.new
    end
  end
end
