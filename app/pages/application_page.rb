# frozen_string_literal: true

require "capybara/dsl"
# require "webdrivers/chromedriver" # ローカル向け

class ApplicationPage
  include Capybara::DSL
end
