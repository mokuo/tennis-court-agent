# frozen_string_literal: true

module Yokohama
  class DateSelectionPage < BasePage
    def available_dates
      days.map do |day|
        Date.new(year, month, day)
      end
    end

    def click_next_month
      click_button("翌月")
      self.class.new
    end

    def click_date(date)
      return click_next_month.click_date(date) if (month + 1) == date.month

      find("input[value='#{date.day}']").click

      Yokohama::ReservationFrameSelectionPage.new
    end

    private

    def year
      @year ||= within("select[name='LST_JUMPNEN']") do
        find("option[selected]").value.to_i
      end
    end

    def month
      @month = within("select[name='LST_JUMPGETU']") do
        find("option[selected]").value.to_i
      end
    end

    def days
      @days ||= within("table#calendar") do
        all("input[type='button']").map { |input| input.value.to_i }
      end
    end
  end
end
