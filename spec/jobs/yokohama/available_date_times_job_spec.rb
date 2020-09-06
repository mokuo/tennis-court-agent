# frozen_string_literal: true

class TestWorkflow
  attr_reader :park_name, :reservation_frames, :started

  def initialize(park_name, reservation_frames)
    @park_name = park_name
    @reservation_frames = reservation_frames
    @started = false
  end

  def self.create(park_name, reservation_frames)
    new(park_name, reservation_frames)
  end

  def start!
    @started = true
  end
end

RSpec.describe Yokohama::AvailableDateTimesJob, type: :feature do
  describe "#perform" do
    subject(:get_reservation_frames) { described_class.new(params).perform }

    let!(:park_name) { "三ツ沢公園" }
    let!(:available_date) do
      available_dates, _page = Yokohama::TopPage.open
                                                .click_check_availability
                                                .click_sports
                                                .click_tennis_court
                                                .click_park(park_name)
                                                .click_tennis_court
                                                .available_dates
      # NOTE: 最初の日付だと、前日のため予約できない場合が多い
      available_dates.last.strftime("%Y-%m-%d")
    end
    let!(:params) do
      { params: { park_name: park_name, available_date: available_date, next_workflow_class: TestWorkflow } }
    end

    it "指定された公園の予約枠を見に行く" do
      test_workflow = get_reservation_frames
      expect(test_workflow.park_name).to eq "三ツ沢公園"
    end

    it "予約枠を取得する" do
      test_workflow = get_reservation_frames
      expect(test_workflow.reservation_frames.count).to be > 0
    end

    it "Yokohama::ReservationFrame 型の配列を返す" do
      test_workflow = get_reservation_frames
      expect(test_workflow.reservation_frames).to all be_a(Yokohama::ReservationFrame)
    end

    it "ReservationStatusCheckWorkflow をスタートする" do
      test_workflow = get_reservation_frames
      expect(test_workflow.started).to be true
    end
  end
end
