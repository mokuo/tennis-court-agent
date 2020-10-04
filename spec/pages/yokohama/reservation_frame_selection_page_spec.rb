# frozen_string_literal: true

RSpec.describe Yokohama::ReservationFrameSelectionPage, type: :feature do
  let!(:park_name) { "三ツ沢公園" }
  let!(:available_dates) do
    Yokohama::TopPage.open
                     .login
                     .click_check_availability
                     .click_sports
                     .click_tennis_court
                     .click_park(park_name)
                     .click_tennis_court
                     .available_dates
  end

  describe "#reservation_frames" do
    subject(:reservation_frames) do
      Yokohama::TopPage.open
                       .login
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park(park_name)
                       .click_tennis_court
                       .click_date(available_dates.last) # NOTE: 最初の日付だと、前日のため予約できない場合が多い
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
      Yokohama::TopPage.open
                       .login
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park(park_name)
                       .click_tennis_court
                       .click_date(available_dates.last) # NOTE: 最初の日付だと、前日のため予約できない場合が多い
    end
    let!(:reservation_frame) { reservation_frame_selection_page.reservation_frames.first }

    # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
    it "渡された予約枠を選択する" do
      selected_reservation_frame_selection_page = click_reservation_frame
      if selected_reservation_frame_selection_page.error_page?
        expect(page).to have_content("選択した枠はキャンセル枠のため、現在予約できません。")
      else
        tennis_court_name = reservation_frame.tennis_court_name
        tennis_court_row_element = selected_reservation_frame_selection_page
                                   .find_tennis_court_tr_element(tennis_court_name)
        selected_input_element = tennis_court_row_element.find("td.waku_sentaku input")
        onclick_attr_str = selected_input_element[:onclick]
        selected_reservation_frame = Yokohama::ReservationFrame.build(tennis_court_name, onclick_attr_str)

        expect(selected_reservation_frame).to eql reservation_frame
      end
    end
    # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations

    # rubocop: disable RSpec/MultipleExpectations
    it "予約枠指定ページに留まるか、エラーページに遷移する" do
      if click_reservation_frame.error_page?
        expect(page).to have_content("エラー")
      else
        expect(page).to have_content("予約枠指定")
      end
    end
    # rubocop: enable RSpec/MultipleExpectations

    it "自身のオブジェクトを返す" do
      expect(click_reservation_frame).to be_a(described_class)
    end

    it "新しいオブジェクトを返す" do
      expect(click_reservation_frame).not_to be reservation_frame_selection_page
    end
  end

  describe "#click_next" do
    let!(:reservation_frame_selection_page) do
      Yokohama::TopPage.open
                       .login
                       .click_check_availability
                       .click_sports
                       .click_tennis_court
                       .click_park(park_name)
                       .click_tennis_court
                       .click_date(available_dates.last) # NOTE: 最初の日付だと、前日のため予約できない場合が多い
    end
    let!(:reservation_frame) { reservation_frame_selection_page.reservation_frames.first }

    # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
    it "予約内容確認ページに遷移する" do
      selected_reservation_frame_selection_page = reservation_frame_selection_page
                                                  .click_reservation_frame(reservation_frame)
      if selected_reservation_frame_selection_page.error_page?
        expect(page).to have_content("選択した枠はキャンセル枠のため、現在予約できません。")
      else
        selected_reservation_frame_selection_page.click_next
        expect(page).to have_content "予約内容確認"
      end
    end
    # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations

    # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
    it "Yokohama::ReservationConfirmationPage オブジェクトを返す" do
      selected_reservation_frame_selection_page = reservation_frame_selection_page
                                                  .click_reservation_frame(reservation_frame)
      if selected_reservation_frame_selection_page.error_page?
        expect(page).to have_content("選択した枠はキャンセル枠のため、現在予約できません。")
      else
        expect(selected_reservation_frame_selection_page.click_next).to be_a(Yokohama::ReservationConfirmationPage)
      end
    end
    # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
  end
end
