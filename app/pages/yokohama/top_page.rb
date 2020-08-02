# frozen_string_literal: true

require "capybara/dsl"
require "webdrivers/chromedriver"

module Yokohama
  class TopPage
    include Capybara::DSL

    def initialize
      visit("https://yoyaku.city.yokohama.lg.jp")
    end
  end
end
