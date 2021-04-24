# frozen_string_literal: true

module Yokohama
  module Mobile
    class MessagePage < BasePage
      def click_next
        find("input[value='次へ']").click
        Yokohama::Mobile::ReservationPage.new
      end
    end
  end
end
