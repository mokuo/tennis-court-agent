# frozen_string_literal: true

require Rails.root.join("domain/models/available_date")

module Yokohama
  class DateSelectionPage < BasePage
    class InfiniteLoopError < StandardError; end

    def available_dates
      days.map do |day|
        date = Date.new(year, month, day)
        AvailableDate.new(date)
      end
    end

    def click_next_month
      # NOTE: `click_button("翌月")` だと `Capybara::ElementNotFound` が頻発する
      find("img[alt='翌月']").click
      self.class.new
    end

    def click_date(date)
      # NOTE: `(month + 1) == date.month` だと12月でバグになる
      if month == date.prev_month.month
        next_month_page = click_next_month
        return next_month_page.click_date(date)
      end

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
      @month ||= within("select[name='LST_JUMPGETU']") do
        find("option[selected]").value.to_i
      end
    end

    def days
      @days = within("table#calendar") do
        all("input[type='button']").map { |input| input.value.to_i }
      end
    end
  end
end
