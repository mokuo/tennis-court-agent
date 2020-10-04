# frozen_string_literal: true

module Yokohama
  class BasePage < ApplicationPage
    def error_page?
      page.has_text?("エラー")
    end

    def logged_in?
      !page.has_text?("こんにちはゲストさん。ログインしてください。")
    end
  end
end
