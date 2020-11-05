# frozen_string_literal: true

require Rails.root.join("domain/models/availability_check_identifier")
require Rails.root.join("domain/models/yokohama/reservation_frame")
require Rails.root.join("domain/models/yokohama/reservation_status_checked")

RSpec.describe QueryService do
  describe "#reservation_frames" do
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:reservation_frame) do
      Yokohama::ReservationFrame.new(
        park_name: "公園１",
        tennis_court_name: "テニスコート１",
        start_date_time: Time.current,
        end_date_time: Time.current.next_day,
        now: true
      )
    end
    let!(:reservation_status_checked) do
      Yokohama::ReservationStatusChecked.new(
        availability_check_identifier: identifier,
        published_at: Time.current,
        reservation_frame: reservation_frame
      )
    end

    it "ReservationFrame の配列を返す" do
      Event.persist!(reservation_status_checked.to_hash)
      reservation_frames = described_class.new.reservation_frames(identifier)
      expect(reservation_frames.first.eql?(reservation_frame)).to be true
    end
  end
end
