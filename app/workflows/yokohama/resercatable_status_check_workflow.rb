# frozen_string_literal: true

module Yokohama
  class ReservationStatusCheckWorkflow < Gush::Workflow
    def configure(park_name, reservation_frames)
      reservation_status_check_jobs = reservation_frames.map do |reservation_frame|
        run ReservationStatusCheckJob, params: { park_name: park_name, reservation_frame: reservation_frame }
      end

      run NortificationJob, params: { park_name: park_name }, after: reservation_status_check_jobs
    end
  end
end
