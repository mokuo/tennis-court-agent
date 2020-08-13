# frozen_string_literal: true

class TestWorkflow
  attr_reader :park_name, :available_dates, :started

  def initialize(park_name, available_dates)
    @park_name = park_name
    @available_dates = available_dates
    @started = false
  end

  def self.create(park_name, available_dates)
    new(park_name, available_dates)
  end

  def start!
    @started = true
  end
end

RSpec.describe Yokohama::AvailableDatesJob, type: :feature do
  describe "#perform" do
    subject(:collect_available_dates) { job.perform }

    let!(:params) do
      { params: { park_name: "富岡西公園", next_workflow_class: TestWorkflow } }
    end
    let!(:job) { described_class.new(params) }

    it "指定された公園の利用可能日を収集すること" do
      test_workflow = collect_available_dates
      expect(test_workflow.park_name).to eq "富岡西公園"

      available_dates = test_workflow.available_dates
      expect(available_dates).to be_a(Array)
      # NOTE: 平日も含めれば、一日も空きがないということはないだろう
      expect(available_dates.count).to be > 0
      expect(available_dates).to all be_a(Date)
    end

    it "AvailableDateTimesWorkflow をスタートすること" do
      test_workflow = collect_available_dates
      expect(test_workflow.started).to be true
    end
  end
end
