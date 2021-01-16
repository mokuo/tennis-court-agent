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
    ReservationJob.perform_later(rf.to_hash)
    reservation_frame.update!(state: :reserving)
  end

  def reserve_tomorrow_morning(reservation_frame)
    rf = reservation_frame.to_domain_model
    # NOTE: ログを見ると、指定した時間の2, 3秒後にスタートしているので、その周辺に連続で実行されるようにする
    start_time = Date.tomorrow.beginning_of_day + rf.opening_hour.hours - Constants::PARALLEL_RESERVATION_JOBS.seconds
    Constants::PARALLEL_RESERVATION_JOBS.times do |n|
      _reserve_tomorrow_morning(rf, start_time + n.seconds, n)
    end
    reservation_frame.update!(state: :will_reserve)
  end

  def _reserve_tomorrow_morning(reservation_frame, wait_until, num)
    ReservationJob
      .set(wait_until: wait_until)
      .perform_later(reservation_frame.to_hash, num)
  end
end
