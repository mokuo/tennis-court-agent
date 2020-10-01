# frozen_string_literal: true

require Rails.root.join("domain/pages/yokohama/base_page")

module Yokohama
  class ReservationConfirmationPage < BasePage
    def reservatable?
      page.has_text?("予約内容確認")
    end
  end
end
