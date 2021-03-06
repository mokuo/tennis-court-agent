# frozen_string_literal: true

require Rails.root.join("domain/models/yokohama/reservation_frame")

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

  describe "#organization_name_ja" do
    it { expect(described_class.new.organization_name_ja).to eq "横浜市" }
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

  describe "#eql_frame?" do
    subject(:eql?) { reservation_frame.eql_frame?(other_reservation_frame) }

    let!(:reservation_frame) do
      described_class.new(
        park_name: "公園１",
        tennis_court_name: "テニスコート１",
        start_date_time: Time.zone.local(2020, 8, 19, 15),
        end_date_time: Time.zone.local(2020, 8, 19, 17),
        now: nil
      )
    end
    let!(:other_reservation_frame) do
      described_class.new(
        {
          park_name: park_name,
          tennis_court_name: tennis_court_name,
          start_date_time: start_date_time,
          end_date_time: end_date_time,
          now: true
        }
      )
    end

    where(:park_name, :tennis_court_name, :start_date_time, :end_date_time, :result) do
      [
        ["公園１", "テニスコート１", Time.zone.local(2020, 8, 19, 15), Time.zone.local(2020, 8, 19, 17), true],
        ["公園２", "テニスコート１", Time.zone.local(2020, 8, 19, 15), Time.zone.local(2020, 8, 19, 17), false],
        ["公園１", "テニスコート２", Time.zone.local(2020, 8, 19, 15), Time.zone.local(2020, 8, 19, 17), false],
        ["公園１", "テニスコート１", Time.zone.local(2020, 8, 19, 13), Time.zone.local(2020, 8, 19, 17), false],
        ["公園１", "テニスコート１", Time.zone.local(2020, 8, 19, 15), Time.zone.local(2020, 8, 19, 19), false]
      ]
    end

    with_them do
      it { is_expected.to be result }
    end
  end

  describe "eql?" do
    subject(:eql?) { reservation_frame.eql?(other_reservation_frame) }

    let!(:reservation_frame) do
      described_class.new(
        park_name: "公園１",
        tennis_court_name: "テニスコート１",
        start_date_time: Time.zone.local(2020, 8, 19, 15),
        end_date_time: Time.zone.local(2020, 8, 19, 17),
        now: true
      )
    end
    let!(:other_reservation_frame) do
      described_class.new(
        {
          park_name: park_name,
          tennis_court_name: tennis_court_name,
          start_date_time: start_date_time,
          end_date_time: end_date_time,
          now: now
        }
      )
    end

    where(:park_name, :tennis_court_name, :start_date_time, :end_date_time, :now, :result) do
      [
        ["公園１", "テニスコート１", Time.zone.local(2020, 8, 19, 15), Time.zone.local(2020, 8, 19, 17), true, true],
        ["公園２", "テニスコート１", Time.zone.local(2020, 8, 19, 15), Time.zone.local(2020, 8, 19, 17), true, false],
        ["公園１", "テニスコート２", Time.zone.local(2020, 8, 19, 15), Time.zone.local(2020, 8, 19, 17), true, false],
        ["公園１", "テニスコート１", Time.zone.local(2020, 8, 19, 13), Time.zone.local(2020, 8, 19, 17), true, false],
        ["公園１", "テニスコート１", Time.zone.local(2020, 8, 19, 15), Time.zone.local(2020, 8, 19, 19), true, false],
        ["公園１", "テニスコート１", Time.zone.local(2020, 8, 19, 15), Time.zone.local(2020, 8, 19, 17), false, false]
      ]
    end

    with_them do
      it { is_expected.to be result }
    end
  end

  describe "#hash" do
    subject(:hash) { reservation_frame.hash }

    let!(:reservation_frame) do
      described_class.new(
        { tennis_court_name: "テニスコート１",
          start_date_time: Time.zone.local(2020, 8, 19, 15),
          end_date_time: Time.zone.local(2020, 8, 19, 17) }
      )
    end

    context "eql? の場合" do
      let(:other_reservation_frame) do
        described_class.new(
          { tennis_court_name: "テニスコート１",
            start_date_time: Time.zone.local(2020, 8, 19, 15),
            end_date_time: Time.zone.local(2020, 8, 19, 17) }
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
            end_date_time: Time.zone.local(2020, 8, 19, 17) }
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
          { park_name: "公園１",
            tennis_court_name: "公園１\nテニスコート１",
            start_date_time: Time.zone.local(2020, 8, 22, 15),
            end_date_time: Time.zone.local(2020, 8, 22, 17),
            now: true }
        )
      end

      it { is_expected.to eq "公園１ テニスコート１ 2020/08/22（土） 15:00~17:00 今すぐ予約可能" }
    end

    context "翌日７時に予約可能な場合" do
      let(:reservation_frame) do
        described_class.new(
          { park_name: "公園１",
            tennis_court_name: "公園１\nテニスコート１",
            start_date_time: Time.zone.local(2020, 8, 22, 15),
            end_date_time: Time.zone.local(2020, 8, 22, 17),
            now: false }
        )
      end

      it { is_expected.to eq "公園１ テニスコート１ 2020/08/22（土） 15:00~17:00 翌日7時に予約可能" }
    end
  end

  describe "#to_hash & .from_hash" do
    it "Hash に変換 & インスタンスを再構築できる" do
      current = Time.current
      reservation_frame = described_class.new(
        tennis_court_name: "公園１",
        start_date_time: current,
        end_date_time: current.change(hour: current.hour + 2)
      )
      rebuild_reservation_frame = described_class.from_hash(reservation_frame.to_hash)
      expect(rebuild_reservation_frame.eql?(reservation_frame)).to be true
    end
  end

  describe "#plain_tennis_court_name" do
    subject(:plain_tennis_court_name) { reservation_frame.plain_tennis_court_name }

    let!(:reservation_frame) do
      described_class.new(
        park_name: "公園A",
        tennis_court_name: "公園A\nテニスコート1"
      )
    end

    it "公園名を除いたテニスコート名を返す" do
      expect(plain_tennis_court_name).to eq "テニスコート1"
    end
  end
end
