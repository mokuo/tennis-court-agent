# frozen_string_literal: true

class CreateReservationFramesJob < ApplicationJob
  queue_as :default

  def perform(identifier)
    reservation_frames = query_service.reservation_frames(identifier)

    ActiveRecord::Base.transaction do
      reservation_frames.each do |domain_model|
        rf = ReservationFrame.from_domain_model(domain_model)
        rf.availability_check_identifier = identifier
        rf.save!
      end
    end
  end

  def query_service
    QueryService.new
  end
end
