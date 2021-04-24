# frozen_string_literal: true

module Yokohama
  module Mobile
    class ReservationPage < BasePage
      def click_confirmation
        click_button("予約確認画面へ")
        Yokohama::Mobile::ReservationConfirmationPage.new
      end
    end
  end
end
