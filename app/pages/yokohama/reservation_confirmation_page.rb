# frozen_string_literal: true

module Yokohama
  class ReservationConfirmationPage < BasePage
    def reservatable?
      page.has_text?("予約内容確認")
    end
  end
end
