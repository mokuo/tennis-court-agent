# frozen_string_literal: true

module Yokohama
  module Mobile
    class ReservationApplicationPage < BasePage
      def click_sports
        click_link("スポーツ")
        self.class.new
      end

      def click_park(park_name)
        click_link(park_name)
        self.class.new
      end

      def click_tennis_court
        click_link("テニスコート（公園）")
        TennisCourtSelectionPage.new
      end
    end
  end
end
