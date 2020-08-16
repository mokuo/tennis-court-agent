# frozen_string_literal: true

module Yokohama
  class FieldTypeSelectionPage < BasePage
    def click_tennis_court
      click_button("テニスコート（公園）")
      Yokohama::DateSpecificationPage.new
    end
  end
end
