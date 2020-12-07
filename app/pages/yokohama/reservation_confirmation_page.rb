# frozen_string_literal: true

module Yokohama
  class ReservationConfirmationPage < BasePage
    def reservatable?
      page.has_text?("予約内容確認")
    end

    def click_next
      click_button("次へ")
      Yokohama::ReservationConfirmationPage.new
    end

    def reserve
      click_button("予約")
      Yokohama::ReservationCompletePage.new
    end
  end
end
