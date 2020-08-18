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

  describe "#click_reservation_frame"

  describe "#click_next"
end
