# frozen_string_literal: true

module Yokohama
  module Mobile
    class ReservationFrameSelectionPage < BasePage
      class ReservationFrameNotSelectedError < StandardError; end

      class TimeFrame
        # ex) "0900-1100 ： ×"
        #     "1500-1700 ： ○ ○"
        #     "1500-1700 ： ○ ●"（選択済み）
        include ActiveModel::Model
        include ActiveModel::Attributes

        attribute :time, :string
        attribute :reservable, :boolean
        attribute :selected, :boolean

        def equal_time?(reservation_frame)
          time ==
            "#{reservation_frame.start_date_time.strftime('%H%M')}-#{reservation_frame.end_date_time.strftime('%H%M')}"
        end
      end

      REGEX = /(\d{4}-\d{4}) ： ([×○]) ?([○●]?)/.freeze

      def click_reservation_frame(reservation_frame)
        index = reservable_time_frames.find_index { |tf| tf.equal_time?(reservation_frame) }
        find_all("form a")[index].click

        self.class.new
      end

      # NOTE: 予約枠を選択すると「ログイン」ボタンが現れる
      def click_login
        click_button("ログイン")
        Yokohama::Mobile::LoginPage.new
      end

      private

      def reservation_frame_clicked?(reservation_frame)
        time_frame = reservable_time_frames.find { |tf| tf.equal_time?(reservation_frame) }
        time_frame.selected
      end

      def reservable_time_frames
        time_frames.filter(&:reservable)
      end

      def time_frames
        form_element = find("form")
        text = form_element.text
        text.scan(REGEX).map do |match_strs|
          TimeFrame.new(
            time: match_strs[0],
            reservable: match_strs[1] == "○",
            selected: match_strs[2] == "●"
          )
        end
      end
    end
  end
end
