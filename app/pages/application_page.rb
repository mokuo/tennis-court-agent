# frozen_string_literal: true

require "capybara/dsl"
require "webdrivers/chromedriver"

class ApplicationPage
  include Capybara::DSL

  def error_page?
    page.has_text?("エラー")
  end
end
