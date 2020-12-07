# frozen_string_literal: true

module Yokohama
  class ReservationCompletePage < BasePage
    def success?
      page.has_text?("予約完了")
    end
  end
end
