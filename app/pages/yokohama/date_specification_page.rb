# frozen_string_literal: true

module Yokohama
  class DateSpecificationPage < ApplicationPage
    def available_dates
      days.map do |day|
        Date.new(year, month, day)
      end
    end

    def click_next_month
      click_button("翌月")
      Yokohama::DateSpecificationPage.new
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
