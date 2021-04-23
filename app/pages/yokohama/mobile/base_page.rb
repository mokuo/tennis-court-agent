# frozen_string_literal: true

module Yokohama
  module Mobile
    class BasePage < ApplicationPage
      def error_page?
        page.has_text?("エラー")
      end
    end
  end
end
