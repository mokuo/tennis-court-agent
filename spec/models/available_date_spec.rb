# frozen_string_literal: true

RSpec.describe AvailableDate, type: :model do
  describe "#check_target?" do
    subject(:check_target?) { available_date.check_target?(date) }

    let!(:available_date) { described_class.new }

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
end
