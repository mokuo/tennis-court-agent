# frozen_string_literal: true

module Yokohama
  class InspectEventsJob < ApplicationJob
    queue_as :default

    def perform(identifier)
      service.inspect_events(identifier)
    end

    private

    def service
      YokohamaService.new
    end
  end
end
