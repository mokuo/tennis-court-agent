# frozen_string_literal: true

require Rails.root.join("domain/pages/domain_page")

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
