# frozen_string_literal: true

require Rails.root.join("domain/services/reservation_frames_service")
require Rails.root.join("domain/models/yokohama/reservation_frame")

RSpec.describe ReservationFramesService do
  describe "#sort" do
    let!(:reservation_frame_1) do
      Yokohama::ReservationFrame.new(
        {
          park_name: "B公園",
          tennis_court_name: "B公園 テニスコート９",
          start_date_time: Time.zone.local(2020, 8, 22, 9),
          end_date_time: Time.zone.local(2020, 8, 22, 11),
          now: true
        }
      )
    end
    let!(:reservation_frame_2) do
      Yokohama::ReservationFrame.new(
        {
          park_name: "A公園",
          tennis_court_name: "A公園 テニスコート１０",
          start_date_time: Time.zone.local(2020, 8, 22, 11),
          end_date_time: Time.zone.local(2020, 8, 22, 13),
          now: true
        }
      )
    end
    let!(:reservation_frame_3) do
      Yokohama::ReservationFrame.new(
        {
          park_name: "A公園",
          tennis_court_name: "A公園 テニスコート９",
          start_date_time: Time.zone.local(2020, 8, 22, 11),
          end_date_time: Time.zone.local(2020, 8, 22, 13),
          now: true
        }
      )
    end
    let!(:reservation_frame_4) do
      Yokohama::ReservationFrame.new(
        {
          park_name: "A公園",
          tennis_court_name: "A公園 テニスコート９",
          start_date_time: Time.zone.local(2020, 8, 22, 13),
          end_date_time: Time.zone.local(2020, 8, 22, 15),
          now: true
        }
      )
    end
    let!(:reservation_frames) do
      [
        reservation_frame_1,
        reservation_frame_2,
        reservation_frame_3,
        reservation_frame_4
      ]
    end

    # rubocop:disable RSpec/MultipleExpectations
    it "tennis_court_name, start_date_time の順に並び替える" do
      result = described_class.new.sort(reservation_frames)
      expect(result[0].eql?(reservation_frame_3)).to be true
      expect(result[1].eql?(reservation_frame_4)).to be true
      expect(result[2].eql?(reservation_frame_2)).to be true
      expect(result[3].eql?(reservation_frame_1)).to be true
    end
    # rubocop:enable RSpec/MultipleExpectations
  end
end
