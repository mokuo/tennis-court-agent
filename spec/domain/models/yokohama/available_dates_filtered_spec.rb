# frozen_string_literal: true

require Rails.root.join("domain/models/availability_check_identifier")
require Rails.root.join("domain/models/available_date")
require Rails.root.join("domain/models/yokohama/available_dates_filtered")
require Rails.root.join("domain/models/yokohama/reservation_frames_found")

RSpec.describe Yokohama::AvailableDatesFiltered do
  describe "#children_finished?" do
    subject(:children_finished?) { domain_event.children_finished?(domain_events) }

    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:now) { Time.current }
    let!(:domain_event) do
      described_class.new(
        park_name: "公園１",
        available_dates: [
          AvailableDate.new(Date.current),
          AvailableDate.new(Date.tomorrow)
        ],
        availability_check_identifier: identifier,
        published_at: now
      )
    end

    context "後続のイベントが完了している時" do
      let(:domain_events) do
        [
          domain_event,
          Yokohama::ReservationFramesFound.new(
            park_name: "公園１",
            availability_check_identifier: identifier,
            available_date: AvailableDate.new(Date.current),
            reservation_frames: [],
            published_at: now
          ),
          Yokohama::ReservationFramesFound.new(
            park_name: "公園１",
            availability_check_identifier: identifier,
            available_date: AvailableDate.new(Date.tomorrow),
            reservation_frames: [],
            published_at: now
          )
        ]
      end

      it { is_expected.to eq true }
    end

    context "後続のイベントが完了していない時" do
      let(:domain_events) do
        [
          domain_event,
          Yokohama::ReservationFramesFound.new(
            park_name: "公園１",
            availability_check_identifier: identifier,
            available_date: AvailableDate.new(Date.current),
            reservation_frames: [],
            published_at: now
          )
        ]
      end

      it { is_expected.to eq false }
    end
  end
end
