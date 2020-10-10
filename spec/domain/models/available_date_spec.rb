# frozen_string_literal: true

require Rails.root.join("domain/models/available_date")

RSpec.describe AvailableDate, type: :model do
  describe "#check_target?" do
    subject(:check_target?) { described_class.new(date).check_target? }

    context "土曜日の場合" do
      let(:date) { Date.new(2020, 8, 15) }

      it { is_expected.to be true }
    end

    context "日曜日の場合" do
      let(:date) { Date.new(2020, 8, 16) }

      it { is_expected.to be true }
    end

    context "国民の祝日の場合" do
      let(:date) { Date.new(2020, 1, 13) }

      it { is_expected.to be true }
    end

    context "平日の場合" do
      let(:date) { Date.new(2020, 8, 17) }

      it { is_expected.to be false }
    end
  end

  describe "#to_date" do
    subject(:to_date) { described_class.new(date).to_date }

    let!(:date) { Date.current }

    it "自身の日付を返す" do
      expect(to_date).to eq date
    end

    it "Date 型を返す" do
      expect(to_date).to be_a(Date)
    end
  end
end
