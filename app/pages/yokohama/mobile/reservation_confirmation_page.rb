# frozen_string_literal: true

module Yokohama
  module Mobile
    class ReservationConfirmationPage < BasePage
      def click_rerservation
        click_link("予約")
        Yokohama::Mobile::ReservationDonePage.new
      end
    end
  end
end
