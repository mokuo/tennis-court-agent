# frozen_string_literal: true

require Rails.root.join("domain/models/yokohama/reservation_frame")

class ReservationFramesController < ApplicationController
  def index
    @reservation_frames = ReservationFrame.all.map(&:to_domain_model)
  end

  def reserve
    reservation_frame = ReservationFrame.find(params[:id])
    if reservation_frame.now
      reserve_now(reservation_frame)
    else
      reserve_tomorrow_morning(reservation_frame)
    end

    flash[:success] = "予約処理を開始しました。"
    redirect_to reservation_frames_url
  end

  private

  def reserve_now(reservation_frame)
    ReservationJob.perform_later(reservation_frame.to_domain_model.to_hash)
    reservation_frame.update!(state: :reserving)
  end

  def reserve_tomorrow_morning(reservation_frame)
    ReservationJob.set(wait_until: Date.tomorrow.beginning_of_day + reservation_frame.opening_hour.hours)
                  .perform_later(reservation_frame.to_domain_model.to_hash)
    reservation_frame.update!(state: :will_reserve)
  end
end
