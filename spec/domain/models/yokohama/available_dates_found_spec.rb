# frozen_string_literal: true

require Rails.root.join("domain/models/availability_check_identifier")
require Rails.root.join("domain/models/available_date")
require Rails.root.join("domain/models/yokohama/available_dates_found")
require Rails.root.join("domain/models/yokohama/available_dates_filtered")

RSpec.describe Yokohama::AvailableDatesFound do
  describe "#children_finished?" do
    subject(:children_finished?) { domain_event.children_finished?(domain_events) }

    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:now) { Time.current }

    context "後続のイベントが完了している時" do
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
      let(:domain_events) do
        [
          domain_event,
          Yokohama::AvailableDatesFiltered.new(
            park_name: "公園１",
            availability_check_identifier: identifier,
            published_at: now,
            available_dates: []
          )
        ]
      end

      it { is_expected.to eq true }
    end

    context "後続のイベントが完了していない時" do
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
      let(:domain_events) { [domain_event] }

      it { is_expected.to eq false }
    end

    context "利用可能日がない時" do
      let(:domain_event) do
        described_class.new(
          park_name: "公園１",
          available_dates: [],
          availability_check_identifier: identifier,
          published_at: now
        )
      end
      let(:domain_events) { [] }

      it { is_expected.to eq true }
    end
  end
end
