# frozen_string_literal: true

module Yokohama
  class TopPage < ApplicationPage
    def initialize
      visit("https://yoyaku.city.yokohama.lg.jp")
    end
  end
end
