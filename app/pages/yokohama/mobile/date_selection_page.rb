# frozen_string_literal: true

module Yokohama
  module Mobile
    class DateSelectionPage < BasePage
      # NOTE: 一つ前のページで選択した日付が先頭に来る
      def click_first_date
        # NOTE: find メソッドだとエラーになる
        #       #<Capybara::Ambiguous: Ambiguous match, found 3 elements matching visible css "font a">
        first("font a").click
        ReservationFrameSelectionPage.new
      end
    end
  end
end
