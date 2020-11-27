# frozen_string_literal: true

require "capybara/dsl"
# NOTE: ローカルで動かす場合も必要
require "webdrivers/chromedriver" if ENV["CI"].present?

class ApplicationPage
  include Capybara::DSL
end
