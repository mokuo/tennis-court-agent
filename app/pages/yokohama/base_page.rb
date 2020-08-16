# frozen_string_literal: true

module Yokohama
  class BasePage < ApplicationPage
    def error_page?
      page.has_text?("エラー")
    end
  end
end
