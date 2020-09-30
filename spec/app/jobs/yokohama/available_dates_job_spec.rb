# frozen_string_literal: true

require Rails.root.join("domain/models/available_date")
class MockService
  def available_dates(_park_name)
    [
      Yokohama::AvailableDate.new
    ]
  end
end

RSpec.describe Yokohama::AvailableDatesJob, type: :feature do
  describe "#perform" do
    subject(:collect_available_dates) { job.perform }

    let!(:params) do
      { park_name: "富岡西公園", next_workflow_class: TestWorkflow }
    end
    let!(:job) { described_class.new(params) }

    it "指定された公園の利用可能日を取得する" do
      test_workflow = collect_available_dates
      expect(test_workflow.park_name).to eq "富岡西公園"
    end

    it "利用可能日が取得できている" do
      # NOTE: 平日も含めれば、一日も空きがないということはないだろう
      test_workflow = collect_available_dates
      expect(test_workflow.available_dates.count).to be > 0
    end

    it "Date 型の配列を返す" do
      test_workflow = collect_available_dates
      expect(test_workflow.available_dates).to all be_a(Date)
    end

    it "AvailableDateTimesWorkflow をスタートする" do
      test_workflow = collect_available_dates
      expect(test_workflow.started).to be true
    end
  end
end
