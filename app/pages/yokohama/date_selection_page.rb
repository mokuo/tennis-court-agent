# frozen_string_literal: true

module Yokohama
  class DateSelectionPage < BasePage
    def initialize
      @available_dates = []
    end

    def available_dates
      available_dates_and_click_next_month
      if error_page?
        @available_dates
      else
        available_dates_and_click_next_month
      end
    end

    def click_date(date)
      if (month + 1) == date.month
        click_next_month
        return click_date(date)
      end

      find("input[value='#{date.day}']").click

      Yokohama::ReservationFrameSelectionPage.new
    end

    private

    def year
      within("select[name='LST_JUMPNEN']") do
        find("option[selected]").value.to_i
      end
    end

    def month
      within("select[name='LST_JUMPGETU']") do
        find("option[selected]").value.to_i
      end
    end

    def days
      within("table#calendar") do
        all("input[type='button']").map { |input| input.value.to_i }
      end
    end

    def click_next_month
      click_button("翌月")
    end

    def available_dates_and_click_next_month
      @available_dates += days.map do |day|
        Date.new(year, month, day)
      end
      click_next_month
    end
  end
end
