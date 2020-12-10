class ReservationFramesController < ApplicationController
  def index
    @reservation_frames = ReservationFrame.all.map(&:to_domain_model)
  end
end
