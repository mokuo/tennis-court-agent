# frozen_string_literal: true

module Yokohama
  class FacilitySelectionPage < ApplicationPage
    class ParkNotFoundError < StandardError; end

    def initialize
      @current_page = 1
    end

    def click_park(park_name)
      find_and_click_button(park_name)
      Yokohama::FieldTypeSelectionPage.new
    end

    private

    def find_and_click_button(button_text)
      raise ParkNotFoundError if @current_page == 3

      if page.has_button?(button_text)
        click_button(button_text)
      else
        click_button("次のページ")
        @current_page += 1

        find_and_click_button(button_text)
      end
    end
  end
end
