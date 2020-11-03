# frozen_string_literal: true

require Rails.root.join("domain/models/availability_check_identifier")
require Rails.root.join("domain/models/yokohama/availability_check_started")
require Rails.root.join("domain/models/yokohama/available_dates_found")

RSpec.describe Yokohama::AvailabilityCheckStarted do
  describe "#children_finished?" do
    subject(:children_finished?) { domain_event.children_finished?(domain_events) }

    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:now) { Time.current }
    let!(:domain_event) do
      described_class.new(
        park_names: %w[公園１ 公園２],
        availability_check_identifier: identifier,
        published_at: now
      )
    end

    context "後続のイベントが全て完了している時" do
      let(:domain_events) do
        [
          domain_event,
          Yokohama::AvailableDatesFound.new(
            park_name: "公園１",
            availability_check_identifier: identifier,
            published_at: now,
            available_dates: []
          ),
          Yokohama::AvailableDatesFound.new(
            park_name: "公園２",
            availability_check_identifier: identifier,
            published_at: now,
            available_dates: []
          )
        ]
      end

      it { is_expected.to eq true }
    end

    context "後続のイベントが完了していない時" do
      let(:domain_events) do
        [
          domain_event,
          Yokohama::AvailableDatesFound.new(
            park_name: "公園１",
            availability_check_identifier: identifier,
            published_at: now,
            available_dates: []
          )
        ]
      end

      it { is_expected.to eq false }
    end
  end
end
