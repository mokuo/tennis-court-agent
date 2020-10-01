# frozen_string_literal: true

require Rails.root.join("domain/pages/yokohama/top_page")

module Yokohama
  class AvailableDateTimesJob < ApplicationJob
    # HACK: 一時的に既存の spec を通しただけ
    def initialize(params)
      @params = params
    end

    def perform
      reservation_frames = get_reservation_frames(params)

      workflow = next_workflow_class.create(params[:park_name], reservation_frames)
      workflow.start!
      workflow
    end

    private

    attr_reader :params

    def get_reservation_frames(params)
      date = Date.parse(params[:available_date])

      Yokohama::TopPage.open
                       .login
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park(params[:park_name])
                       .click_tennis_court
                       .click_date(date)
                       .reservation_frames
    end

    def next_workflow_class
      params[:next_workflow_class] || ReservationStatusCheckWorkflow
    end

    def available_date
      # NOTE: Gush::Workflow の params として渡ってくる時点で YYYY-mm-dd の string になる
      Date.parse(params[:available_date])
    end
  end
end
