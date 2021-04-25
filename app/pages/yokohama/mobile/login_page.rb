# frozen_string_literal: true

module Yokohama
  module Mobile
    class LoginPage < BasePage
      def fill_id(user_number = Rails.application.credentials.yokohama![:user_number])
        find("input[name='ID']").set(user_number)
        self.class.new
      end

      def fill_password(password = Rails.application.credentials.yokohama![:password])
        find("input[name='PWD']").set(password)
        self.class.new
      end

      def click_login
        find("input[value='ﾛｸﾞｲﾝ']").click

        Yokohama::Mobile::MessagePage.new
      end
    end
  end
end
