# frozen_string_literal: true

require Rails.root.join("domain/models/availability_check_identifier")
require Rails.root.join("domain/models/available_date")
require Rails.root.join("domain/models/yokohama/reservation_frame")
require Rails.root.join("domain/models/yokohama/reservation_frames_found")
require Rails.root.join("domain/models/yokohama/reservation_status_checked")

RSpec.describe Yokohama::ReservationFramesFound do
  describe "#children_finished?" do
    subject(:children_finished?) { domain_event.children_finished?(domain_events) }

    let!(:identifier) { AvailabilityCheckIdentifier.build }

    context "後続のイベントが全て完了している時" do
      let!(:domain_event) do
        described_class.new(
          available_date: AvailableDate.new(Date.tomorrow),
          reservation_frames: [reservation_frame_1, reservation_frame_2],
          availability_check_identifier: identifier,
          published_at: Time.current
        )
      end
      let!(:reservation_frame_1) do
        Yokohama::ReservationFrame.new(
          park_name: "公園１",
          tennis_court_name: "テニスコート１",
          start_date_time: Time.current,
          end_date_time: Time.current.next_day
        )
      end
      let!(:reservation_frame_2) do
        Yokohama::ReservationFrame.new(
          park_name: "公園１",
          tennis_court_name: "テニスコート２",
          start_date_time: Time.current,
          end_date_time: Time.current.next_day
        )
      end
      let(:domain_events) do
        reservation_frame_1.now = true
        reservation_frame_2.now = false

        [
          domain_event,
          Yokohama::ReservationStatusChecked.new(
            availability_check_identifier: identifier,
            published_at: Time.current,
            reservation_frame: reservation_frame_1
          ),
          Yokohama::ReservationStatusChecked.new(
            availability_check_identifier: identifier,
            published_at: Time.current,
            reservation_frame: reservation_frame_2
          )
        ]
      end

      it { is_expected.to eq true }
    end

    context "後続のイベントが完了していない時" do
      let!(:domain_event) do
        described_class.new(
          available_date: AvailableDate.new(Date.tomorrow),
          reservation_frames: [reservation_frame_1, reservation_frame_2],
          availability_check_identifier: identifier,
          published_at: Time.current
        )
      end
      let!(:reservation_frame_1) do
        Yokohama::ReservationFrame.new(
          park_name: "公園１",
          tennis_court_name: "テニスコート１",
          start_date_time: Time.current,
          end_date_time: Time.current.next_day
        )
      end
      let!(:reservation_frame_2) do
        Yokohama::ReservationFrame.new(
          park_name: "公園１",
          tennis_court_name: "テニスコート２",
          start_date_time: Time.current,
          end_date_time: Time.current.next_day
        )
      end
      let(:domain_events) do
        reservation_frame_1.now = true

        [
          domain_event,
          Yokohama::ReservationStatusChecked.new(
            availability_check_identifier: identifier,
            published_at: Time.current,
            reservation_frame: reservation_frame_1
          )
        ]
      end

      it { is_expected.to eq false }
    end

    context "予約枠がない時" do
      let(:domain_event) do
        described_class.new(
          available_date: AvailableDate.new(Date.tomorrow),
          reservation_frames: [],
          availability_check_identifier: identifier,
          published_at: Time.current
        )
      end
      let(:domain_events) { [] }

      it { is_expected.to eq true }
    end
  end
end
