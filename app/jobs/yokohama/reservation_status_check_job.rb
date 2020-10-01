# frozen_string_literal: true

require Rails.root.join("domain/pages/yokohama/top_page")

module Yokohama
  class ReservationStatusCheckJob < ApplicationJob
    # HACK: 一時的に既存の spec を通しただけ
    def initialize(params)
      @params = params
    end

    def perform
      reservation_frame = params[:reservation_frame]
      reservation_frame.now = reservatable?(params[:park_name], reservation_frame)
      output({ reservation_frame: reservation_frame })
    end

    private

    attr_reader :params

    def reservatable?(park_name, reservation_frame) # rubocop:disable Metrics/MethodLength
      Yokohama::TopPage.open
                       .login
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park(park_name)
                       .click_tennis_court
                       .click_date(reservation_frame.date)
                       .click_reservation_frame(reservation_frame)
                       .click_next
                       .reservatable?
    end
  end
end
