# frozen_string_literal: true

RSpec.describe Yokohama::ReservationFrame, type: :model do
  describe ".build" do
    subject(:build) { described_class.build("テニスコート１", onclick_attr_str) }

    let!(:onclick_attr_str) do
      "javascript:return fcRSGK306ClickSubmit(FRM_RSGK306,'SEARCH_CHANGE','rsv.bean.RSGK306BusinessClick','RSGK306','150','1500','20200831','15001700','0','','1','4');" # rubocop:disable Layout/LineLength
    end

    it "Yokohama::ReservationFrame オブジェクトを返す" do
      expect(build).to be_a(described_class)
    end

    it "渡されたテニスコート名を持つ" do
      expect(build.tennis_court_name).to eq "テニスコート１"
    end

    it "開始時間を持つ" do
      expect(build.start_date_time).to eq Time.zone.local(2020, 8, 31, 15)
    end

    it "終了時間を持つ" do
      expect(build.end_date_time).to eq Time.zone.local(2020, 8, 31, 17)
    end
  end

  describe "#date_str" do
    subject(:date_str) { reservation_frame.date_str }

    let!(:reservation_frame) do
      described_class.new(
        { tennis_court_name: "テニスコート１",
          start_date_time: Time.zone.local(2020, 8, 19, 15),
          end_date_time: Time.zone.local(2020, 8, 19, 17) }
      )
    end

    it "YYYYmmdd を返す" do
      expect(date_str).to eq "20200819"
    end
  end

  describe "#time_str" do
    subject(:date_str) { reservation_frame.time_str }

    let!(:reservation_frame) do
      described_class.new(
        { tennis_court_name: "テニスコート１",
          start_date_time: Time.zone.local(2020, 8, 19, 15),
          end_date_time: Time.zone.local(2020, 8, 19, 17) }
      )
    end

    it "HHMMHHMM を返す" do
      expect(date_str).to eq "15001700"
    end
  end

  describe "eql?" do
    subject(:eql?) { reservation_frame.eql?(other_reservation_frame) }

    let!(:reservation_frame) do
      described_class.new(
        { tennis_court_name: "テニスコート１",
          start_date_time: Time.zone.local(2020, 8, 19, 15),
          end_date_time: Time.zone.local(2020, 8, 19, 17),
          now: true }
      )
    end

    context "全ての値が等しい時" do
      let(:other_reservation_frame) do
        described_class.new(
          { tennis_court_name: "テニスコート１",
            start_date_time: Time.zone.local(2020, 8, 19, 15),
            end_date_time: Time.zone.local(2020, 8, 19, 17),
            now: true }
        )
      end

      it { is_expected.to be true }
    end

    context "テニスコート名が違う時" do
      let(:other_reservation_frame) do
        described_class.new(
          { tennis_court_name: "テニスコート２",
            start_date_time: Time.zone.local(2020, 8, 19, 15),
            end_date_time: Time.zone.local(2020, 8, 19, 17),
            now: true }
        )
      end

      it { is_expected.to be false }
    end

    context "開始時刻が違う時" do
      let(:other_reservation_frame) do
        described_class.new(
          { tennis_court_name: "テニスコート１",
            start_date_time: Time.zone.local(2020, 8, 19, 13),
            end_date_time: Time.zone.local(2020, 8, 19, 17),
            now: true }
        )
      end

      it { is_expected.to be false }
    end

    context "終了時刻が違う時" do
      let(:other_reservation_frame) do
        described_class.new(
          { tennis_court_name: "テニスコート１",
            start_date_time: Time.zone.local(2020, 8, 19, 15),
            end_date_time: Time.zone.local(2020, 8, 19, 19),
            now: true }
        )
      end

      it { is_expected.to be false }
    end

    context "今すぐ予約可能かどうかが違う時" do
      let(:other_reservation_frame) do
        described_class.new(
          { tennis_court_name: "テニスコート１",
            start_date_time: Time.zone.local(2020, 8, 19, 15),
            end_date_time: Time.zone.local(2020, 8, 19, 17),
            now: false }
        )
      end

      it { is_expected.to be false }
    end
  end

  describe "#hash" do
    subject(:hash) { reservation_frame.hash }

    let!(:reservation_frame) do
      described_class.new(
        { tennis_court_name: "テニスコート１",
          start_date_time: Time.zone.local(2020, 8, 19, 15),
          end_date_time: Time.zone.local(2020, 8, 19, 17),
          now: false }
      )
    end

    context "eql? の場合" do
      let(:other_reservation_frame) do
        described_class.new(
          { tennis_court_name: "テニスコート１",
            start_date_time: Time.zone.local(2020, 8, 19, 15),
            end_date_time: Time.zone.local(2020, 8, 19, 17),
            now: false }
        )
      end

      it "ハッシュ値も一致する" do
        expect(hash).to eq other_reservation_frame.hash
      end
    end

    context "not eql? の場合" do
      let(:other_reservation_frame) do
        described_class.new(
          { tennis_court_name: "テニスコート２",
            start_date_time: Time.zone.local(2020, 8, 19, 15),
            end_date_time: Time.zone.local(2020, 8, 19, 17),
            now: true }
        )
      end

      it "ハッシュ値も一致しない" do
        expect(hash).not_to eq other_reservation_frame.hash
      end
    end
  end

  describe "#to_human" do
    subject(:to_human) { reservation_frame.to_human }

    context "今すぐ予約可能な場合" do
      let(:reservation_frame) do
        described_class.new(
          { tennis_court_name: "テニスコート１",
            start_date_time: Time.zone.local(2020, 8, 22, 15),
            end_date_time: Time.zone.local(2020, 8, 22, 17),
            now: true }
        )
      end

      it { is_expected.to eq "テニスコート１ 2020/08/22（土） 15:00~17:00 今すぐ予約可能" }
    end

    context "翌日７時に予約可能な場合" do
      let(:reservation_frame) do
        described_class.new(
          { tennis_court_name: "テニスコート１",
            start_date_time: Time.zone.local(2020, 8, 22, 15),
            end_date_time: Time.zone.local(2020, 8, 22, 17),
            now: false }
        )
      end

      it { is_expected.to eq "テニスコート１ 2020/08/22（土） 15:00~17:00 翌日７時に予約可能" }
    end
  end
end
