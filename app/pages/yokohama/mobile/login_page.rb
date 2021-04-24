# frozen_string_literal: true

module Yokohama
  module Mobile
    class LoginPage < BasePage
      def login(
        user_number = Rails.application.credentials.yokohama![:user_number],
        password = Rails.application.credentials.yokohama![:password]
      )
        find("input[name='ID']").set(user_number)
        find("input[name='PWD']").set(password)
        find("input[value='ﾛｸﾞｲﾝ']").click

        Yokohama::Mobile::MessagePage.new
      end
    end
  end
end
