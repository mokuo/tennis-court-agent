# frozen_string_literal: true

require Rails.root.join("domain/pages/yokohama/base_page")

module Yokohama
  class TopPage < BasePage
    def self.open
      new.open
    end

    def open
      visit("https://yoyaku.city.yokohama.lg.jp")
      self.class.new
    end

    def login(
      user_number = Rails.application.credentials.yokohama![:user_number],
      password = Rails.application.credentials.yokohama![:password]
    )
      unless logged_in?
        find("input[name='ID']").set(user_number)
        find("input[name='PWD']").set(password)
        click_button("ログイン")
      end

      self.class.new
    end

    def click_check_availability
      click_button("空状況照会・予約（施設から選択）")
      FacilityTypeSelectionPage.new
    end
  end
end
