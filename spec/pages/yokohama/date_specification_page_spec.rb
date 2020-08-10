# frozen_string_literal: true

RSpec.describe Yokohama::DateSpecificationPage, type: :feature do
  describe "#available_dates" do
    subject(:available_dates) do
      Yokohama::TopPage.new
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park("三ツ沢公園")
                       .click_tennis_court
                       .available_dates
    end

    it "利用可能な日付を全て取得する" do
      expect(available_dates.size).to be > 0
    end

    it "Date 型の配列を返す" do
      expect(available_dates).to all(be_a(Date))
    end
  end

  describe "#click_next_month" do
    subject(:click_next_month) do
      Yokohama::TopPage.new
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park("三ツ沢公園")
                       .click_tennis_court
                       .click_next_month
    end

    # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
    it "自身のオブジェクトか Yokohama::ErrorPage オブジェクトを返す" do
      page_object = click_next_month

      if page.has_text?("以降の空き状況は御覧になれません")
        expect(page_object).to be_a(Yokohama::ErrorPage)
      else
        expect(page_object).to be_a(described_class)
      end
    end
    # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
  end
end
