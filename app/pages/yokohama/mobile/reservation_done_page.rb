# frozen_string_literal: true

module Yokohama
  module Mobile
    class ReservationDonePage < BasePage
      def done?
        page.has_text?("予約完了")
      end
    end
  end
end
