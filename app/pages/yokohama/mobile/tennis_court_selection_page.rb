# frozen_string_literal: true

module Yokohama
  module Mobile
    class TennisCourtSelectionPage < BasePage
      def select_date(date)
        select_year(date.year)
        select_month(date.month)
        select_day(date.day)

        self.class.new
      end

      def select_tennis_court(tennis_court_name)
        select(tennis_court_name, from: "sltSISETU")

        self.class.new
      end

      def click_next
        click_button("次へ")

        ReservationFrameSelectionPage.new
      end

      private

      def select_year(year)
        select(year, from: "txtFRIYOUBIY")
      end

      def select_month(month)
        select(month, from: "txtFRIYOUBIM")
      end

      def select_day(day)
        select(day, from: "txtFRIYOUBID")
      end
    end
  end
end
