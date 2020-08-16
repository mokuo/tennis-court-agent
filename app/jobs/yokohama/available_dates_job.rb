# frozen_string_literal: true

module Yokohama
  class AvailableDatesJob < Gush::Job
    def perform
      park_name = params[:park_name]
      available_dates = get_available_dates(park_name)
      workflow = next_workflow_class.create(park_name, available_dates)
      workflow.start!
      workflow
    end

    private

    def get_available_dates(park_name)
      current_month_page = Yokohama::TopPage.open
                                            .click_check_availability
                                            .click_sports
                                            .click_tennis_court
                                            .click_park(park_name)
                                            .click_tennis_court
      available_dates = current_month_page.available_dates
      next_month_page = current_month_page.click_next_month
      available_dates.concat(next_month_page.available_dates) unless next_month_page.error_page?
    end

    def next_workflow_class
      params[:next_workflow_class] || AvailableDateTimesWorkflow
    end
  end
end
