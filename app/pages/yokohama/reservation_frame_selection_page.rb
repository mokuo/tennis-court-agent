# frozen_string_literal: true

module Yokohama
  class ReservationFrameSelectionPage < BasePage
    class MissingSelectButtonError < StandardError; end

    def initialize
      check_logged_in!
    end

    # rubocop:disable Metrics/MethodLength
    def reservation_frames
      result = []

      tennis_court_tr_elements.each do |tennis_court_tr_element|
        columns = tennis_court_tr_element.all("td")
        tennis_court_name = columns[0].text
        reservation_frame_elements = columns.drop(2) # 「施設」「定員」列を取り除く

        reservation_frame_elements.each do |reservation_frame_element|
          # NOTE: `reservation_frame_element.has_button?` で探すことも可能だが遅い
          next if unavailable?(reservation_frame_element.text)

          onclick_attr_str = reservation_frame_element.find("input")[:onclick]
          reservation_frame = Yokohama::ReservationFrame.build(tennis_court_name, onclick_attr_str)
          result.push(reservation_frame)
        end
      end

      result
    end
    # rubocop:enable Metrics/MethodLength

    def click_reservation_frame(reservation_frame)
      tennis_court_tr_element = find_tennis_court_tr_element(reservation_frame.tennis_court_name)
      # NOTE: 部分一致
      input_element = tennis_court_tr_element.find(
        "td input[onclick*='\\'#{reservation_frame.date_str}\\',\\'#{reservation_frame.time_str}\\'']"
      )
      input_element.click

      self.class.new
    end

    def click_next
      # TODO: 予約枠が選択されていることをチェック！
      click_button("次へ")
      Yokohama::ReservationConfirmationPage.new
    end

    def find_tennis_court_tr_element(tennis_court_name)
      tennis_court_tr_elements.find do |e|
        e.find("td:first-child").text == tennis_court_name
      end
    end

    private

    def check_logged_in!
      raise MissingSelectButtonError unless logged_in?
    end

    def unavailable?(text)
      %w[予約済 ×].include?(text)
    end

    def tennis_court_tr_elements
      table_row_elements = all("table#tbl_time tr")
      result = table_row_elements.drop(1) # テーブルのヘッダーを取り除く
      result.pop # 空行を取り除く
      result
    end
  end
end
