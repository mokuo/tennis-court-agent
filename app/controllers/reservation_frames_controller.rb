# frozen_string_literal: true

require Rails.root.join("domain/models/yokohama/reservation_frame")

class ReservationFramesController < ApplicationController
  def index
    @reservation_frames = ReservationFrame.all.map(&:to_domain_model)
    @availability_check = AvailabilityCheck.finished.last
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
    rf = reservation_frame.to_domain_model
    ReservationJob.perform_later(rf.to_hash, waiting: false)
    reservation_frame.update!(state: :reserving)
  end

  def reserve_tomorrow_morning(reservation_frame)
    rf = reservation_frame.to_domain_model
    # NOTE: ログを見ると、指定した時間の2, 3秒後にスタートしているので、その前に実行されるようにする
    # => ログを見ると5秒前でもギリギリだったので、10秒前にしてみる
    ReservationJob
      .set(wait_until: Date.tomorrow.beginning_of_day + rf.opening_hour.hours - 10.seconds)
      .perform_later(rf.to_hash, waiting: true)
    reservation_frame.update!(state: :will_reserve)
  end
end
