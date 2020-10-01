# frozen_string_literal: true

require Rails.root.join("domain/pages/yokohama/top_page")

module Yokohama
  class AvailableDatesJob < ApplicationJob
    queue_as :yokohama

    # HACK: 一時的に既存の spec を通しただけ
    def initialize(params)
      @params = params
    end

    def perform
      park_name = params[:park_name]
      available_dates = get_available_dates(park_name)

      available_date = AvailableDate.new
      filtered_available_dates = available_dates.filter { |d| available_date.check_target?(d) }

      workflow = next_workflow_class(params).create(park_name, filtered_available_dates)
      workflow.start!
      workflow
    end

    private

    attr_reader :params

    def get_available_dates(park_name)
      Yokohama::TopPage.open
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park(park_name)
                       .click_tennis_court
                       .available_dates
    end

    def next_workflow_class(params)
      params[:next_workflow_class] || AvailableDateTimesWorkflow
    end
  end
end
