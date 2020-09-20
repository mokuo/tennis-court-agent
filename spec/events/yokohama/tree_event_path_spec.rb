# frozen_string_literal: true

RSpec.describe Yokohama::TreeEventPath, type: :model do
  describe "#append" do
    let!(:timestamp) { Time.zone.now.to_s(:iso8601) }

    context "when depth 1" do
      let!(:path) { described_class.parse("/#{timestamp}/yokohama") }
      let!(:expected_path) { described_class.parse("/#{timestamp}/yokohama/富岡西公園") }

      it { expect(path.append("富岡西公園").eql?(expected_path)).to be true }
    end
  end

  describe "TreeEventPath attributes" do
    let!(:timestamp) { Time.zone.now.to_s(:iso8601) }
    let!(:organization) { "yokohama" }
    let!(:park) { "富岡西公園" }
    let!(:date) { Date.current }
    let!(:reservation_frame_s) { "11:00~13:00_テニスコート１" }

    context "depth 0" do
      let!(:path) { described_class.parse("/#{timestamp}") }

      it { expect(path.timestamp).to eq timestamp }
      it { expect(path.organization).to eq nil }
      it { expect(path.park).to eq nil }
      it { expect(path.date).to eq nil }
      it { expect(path.reservation_frame).to eq nil }
    end

    context "depth 1" do
      let!(:path) { described_class.parse("/#{timestamp}/#{organization}") }

      it { expect(path.timestamp).to eq timestamp }
      it { expect(path.organization).to eq organization }
      it { expect(path.park).to eq nil }
      it { expect(path.date).to eq nil }
      it { expect(path.reservation_frame).to eq nil }
    end

    context "depth 2" do
      let!(:path) { described_class.parse("/#{timestamp}/#{organization}/#{park}") }

      it { expect(path.timestamp).to eq timestamp }
      it { expect(path.organization).to eq organization }
      it { expect(path.park).to eq park }
      it { expect(path.date).to eq nil }
      it { expect(path.reservation_frame).to eq nil }
    end

    context "depth 3" do
      let!(:path) { described_class.parse("/#{timestamp}/#{organization}/#{park}/#{date}") }

      it { expect(path.timestamp).to eq timestamp }
      it { expect(path.organization).to eq organization }
      it { expect(path.park).to eq park }
      it { expect(path.date).to eq date }
      it { expect(path.reservation_frame).to eq nil }
    end

    context "depth 4" do
      let!(:reservation_frame) do
        Yokohama::ReservationFrame.new(
          {
            start_date_time: Time.zone.parse("#{date} 11:00"),
            end_date_time: Time.zone.parse("#{date} 13:00"),
            tennis_court_name: "テニスコート１"
          }
        )
      end
      let!(:path) { described_class.parse("/#{timestamp}/#{organization}/#{park}/#{date}/#{reservation_frame_s}") }

      it { expect(path.timestamp).to eq timestamp }
      it { expect(path.organization).to eq organization }
      it { expect(path.park).to eq park }
      it { expect(path.date).to eq date }
      it { expect(path.reservation_frame.eql?(reservation_frame)).to be true }
    end

    context "depth 5" do
      let!(:reservation_frame) do
        Yokohama::ReservationFrame.new(
          {
            start_date_time: Time.zone.parse("#{date} 11:00"),
            end_date_time: Time.zone.parse("#{date} 13:00"),
            tennis_court_name: "テニスコート１",
            now: true
          }
        )
      end
      let!(:path) { described_class.parse("/#{timestamp}/#{organization}/#{park}/#{date}/#{reservation_frame_s}/true") }

      it { expect(path.timestamp).to eq timestamp }
      it { expect(path.organization).to eq organization }
      it { expect(path.park).to eq park }
      it { expect(path.date).to eq date }
      it { expect(path.reservation_frame.eql?(reservation_frame)).to be true }
    end
  end
end
