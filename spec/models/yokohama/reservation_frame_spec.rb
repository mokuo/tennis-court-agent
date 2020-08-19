# frozen_string_literal: true

RSpec.describe Yokohama::ReservationFrame, type: :model do
  describe ".build" do
    subject(:build) { described_class.build("テニスコート１", js_onclick_str) }

    let!(:js_onclick_str) do
      "javascript:return fcRSGK306ClickSubmit(FRM_RSGK306,'SEARCH_CHANGE','rsv.bean.RSGK306BusinessClick','RSGK306','150','1500','20200831','15001700','0','','1','4');"
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
end
