# frozen_string_literal: true

require Rails.root.join("domain/models/availability_check_identifier")
require Rails.root.join("domain/models/yokohama/reservation_frame")

RSpec.describe CreateReservationFramesJob, type: :job do
  describe "#perform" do
    let!(:query_service_mock) { instance_double("QueryService") }
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:reservation_frame) do
      Yokohama::ReservationFrame.new(
        park_name: "A公園",
        tennis_court_name: "テニスコート１",
        start_date_time: Time.current,
        end_date_time: Time.current.next_day,
        now: true
      )
    end
    let!(:job) { described_class.new }

    before do
      allow(job).to receive(:query_service).and_return(query_service_mock)
      allow(query_service_mock).to receive(:reservation_frames).with(identifier).and_return([reservation_frame])
    end

    # rubocop:disable RSpec/MultipleExpectations
    it "予約枠を作成する" do
      job.perform(identifier)

      rf = ReservationFrame.last
      expect(rf).to have_attributes(
        availability_check_identifier: identifier,
        now: reservation_frame.now,
        park_name: reservation_frame.park_name,
        tennis_court_name: reservation_frame.tennis_court_name
      )
      expect(rf.start_at.floor).to eq reservation_frame.start_date_time.floor
      expect(rf.end_at.floor).to eq reservation_frame.end_date_time.floor
    end
    # rubocop:enable RSpec/MultipleExpectations
  end
end
