# frozen_string_literal: true

URL = "https://yoyaku.city.yokohama.lg.jp/y/mainservlet/UserPublic?ActionType=LOAD&BeanType=rsv.bean.RSGU001BusinessInit&ViewName=RSGU001&TOKEN_KEY=0713592ba5878b773701792a6b9f26a4"

module Yokohama
  module Mobile
    class TopPage < BasePage
      def self.open
        new.open
      end

      def open
        visit(URL)
        self.class.new
      end

      def click_check_availability
        click_link("空き状況照会・予約申込")
        ReservationApplicationPage.new
      end
    end
  end
end
