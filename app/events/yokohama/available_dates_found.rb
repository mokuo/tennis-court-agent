# frozen_string_literal: true

module Yokohama
  class AvailableDatesFound < DomainTreeEvent
    def register_subscribers
      [
        ->(event) { AvailableDate.filter(event.path, event.children) }
      ]
    end
  end
end
