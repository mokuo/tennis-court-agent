# frozen_string_literal: true

require Rails.root.join("domain/models/yokohama/reservation_frame")

class ReservationFramesController < ApplicationController
  def index
    @reservation_frames = ReservationFrame.all.map(&:to_domain_model)
  end

  def reservate
    reservation_frame = ReservationFrame.find(params[:id])
    # HACK: 横浜市なので、とりあえず翌朝7時で固定
    ReservationJob.set(wait_until: Date.tomorrow.beginning_of_day + 7.hours).perform_later(reservation_frame)
    # TODO: reservation_frame の state 変更と、ビューへの反映
    flash[:success] = "予約処理を開始しました。"
    redirect_to reservation_frames_url
  end
end
