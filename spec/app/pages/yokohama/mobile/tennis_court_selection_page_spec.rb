# frozen_string_literal: true

RSpec.describe Yokohama::Mobile::TennisCourtSelectionPage, type: :feature do
  describe "#select_date" do
    subject(:select_date) do
      Yokohama::Mobile::TopPage.open
                               .click_check_availability
                               .click_sports
                               .click_park("三ツ沢公園")
                               .click_tennis_court
                               .select_date(target_date)
    end

    let!(:target_date) do # NOTE: 全セレクトボックスが初期値から変わるような日付を使う
      today = Date.current
      td = today.next_month.next_day
      # NOTE: 来年までしか選択できないため、next_month, next_day で年が繰り上がる場合を考慮する
      td = td.next_year if today.year == td.year
      td
    end

    # rubocop:disable RSpec/MultipleExpectations
    it "日付が変更されること" do
      select_date

      expect(find("select[name='txtFRIYOUBIY']").value.to_i).to eq target_date.year
      expect(find("select[name='txtFRIYOUBIM']").value.to_i).to eq target_date.month
      expect(find("select[name='txtFRIYOUBID']").value.to_i).to eq target_date.day
    end
    # rubocop:enable RSpec/MultipleExpectations

    it "自身のオブジェクトを返すこと" do
      expect(select_date).to be_a(described_class)
    end
  end

  describe "#select_tennis_court" do
    subject(:select_tennis_court) do
      Yokohama::Mobile::TopPage.open
                               .click_check_availability
                               .click_sports
                               .click_park("三ツ沢公園")
                               .click_tennis_court
                               .select_tennis_court("三ツ沢公園", "三ツ沢公園\nテニスコート２")
    end

    it "テニスコートが選択されること" do
      select_tennis_court

      expect(find("select[name='sltSISETU'] option[selected]").text).to eq "テニスコート２"
    end

    it "自身のオブジェクトを返すこと" do
      expect(select_tennis_court).to be_a(described_class)
    end
  end
end
