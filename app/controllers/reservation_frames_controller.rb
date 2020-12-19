# frozen_string_literal: true

require Rails.root.join("domain/models/yokohama/reservation_frame")

class ReservationFramesController < ApplicationController
  def index
    @reservation_frames = ReservationFrame.all.map(&:to_domain_model)
  end

  def reserve
    reservation_frame = ReservationFrame.find(params[:id])
    # HACK: 横浜市なので、とりあえず翌朝7時で固定
    ReservationJob.set(wait_until: Date.tomorrow.beginning_of_day + 7.hours)
                  .perform_later(reservation_frame.to_domain_model.to_hash)
    reservation_frame.update!(state: :will_reserve)
    flash[:success] = "予約処理を開始しました。"
    redirect_to reservation_frames_url
  end
end
