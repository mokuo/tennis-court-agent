# frozen_string_literal: true

module Yokohama
  class ReservationStatusCheckJob < Gush::Job
    def perform
      reservation_frame = params[:reservation_frame]
      reservation_frame.now = reservatable?(params[:park_name], reservation_frame)
      output({ reservation_frame: reservation_frame })
    end

    private

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
