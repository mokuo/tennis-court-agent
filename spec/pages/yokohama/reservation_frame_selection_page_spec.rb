# frozen_string_literal: true

RSpec.describe Yokohama::ReservationFrameSelectionPage, type: :feature do
  describe "#reservation_frames" do
    subject(:reservation_frames) do
      date_selection_page = Yokohama::TopPage.open
                                             .login
                                             .click_check_availability
                                             .click_sports
                                             .click_tennis_court
                                             .click_park("三ツ沢公園")
                                             .click_tennis_court
      available_dates = date_selection_page.available_dates
      # NOTE: 最初の日付だと、前日のため予約できない場合が多い
      date_selection_page.click_date(available_dates.last)
                         .reservation_frames
    end

    it "利用可能な日時を取得する" do
      expect(reservation_frames.count).to be > 0
    end

    it "Yokohama::ReservationFrame の配列を返す" do
      expect(reservation_frames).to all be_a(Yokohama::ReservationFrame)
    end
  end

  describe "#click_reservation_frame" do
    subject(:click_reservation_frame) { reservation_frame_selection_page.click_reservation_frame(reservation_frame) }

    let!(:reservation_frame_selection_page) do
      date_selection_page = Yokohama::TopPage.open
                                             .login
                                             .click_check_availability
                                             .click_sports
                                             .click_tennis_court
                                             .click_park("三ツ沢公園")
                                             .click_tennis_court
      available_dates = date_selection_page.available_dates
      # NOTE: 最初の日付だと、前日のため予約できない場合が多い
      reservation_frame_selection_page = date_selection_page.click_date(available_dates.last)
    end
    let!(:reservation_frame) { reservation_frame_selection_page.reservation_frames.first }

    it "渡された予約枠を選択する" do
      click_reservation_frame

      tennis_court_name = reservation_frame.tennis_court_name

      table_row_elements = all("table#tbl_time tr")
      tennis_court_row_elements = table_row_elements.drop(1) # テーブルのヘッダーを取り除く
      tennis_court_row_elements.pop # 空行を取り除く
      tennis_court_row_element = tennis_court_row_elements.find do |e|
        e.find("td:first-child").text == tennis_court_name
      end
      selected_input_element = tennis_court_row_element.find("td.waku_sentaku input")
      js_onclick_str = selected_input_element[:onclick]
      selected_reservation_frame = Yokohama::ReservationFrame.build(tennis_court_name, js_onclick_str)

      expect(selected_reservation_frame).to eql reservation_frame
    end

    it "予約枠指定ページに留まる" do
      click_reservation_frame
      expect(page).to have_content "予約枠指定"
    end

    it "自身のオブジェクトを返す" do
      expect(click_reservation_frame).to be_a(described_class)
    end

    it "新しいオブジェクトを返す" do
      expect(click_reservation_frame).not_to be reservation_frame_selection_page
    end
  end

  describe "#click_next"
end
