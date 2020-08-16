# frozen_string_literal: true

module Yokohama
  class TopPage < BasePage
    def initialize
      visit("https://yoyaku.city.yokohama.lg.jp")
    end

    def click_check_availability
      click_button("空状況照会・予約（施設から選択）")
      FacilityTypeSelectionPage.new
    end
  end
end
