# frozen_string_literal: true

RSpec.describe Yokohama::TopPage, type: :feature do
  describe ".new" do
    it "トップページが表示されること" do
      described_class.new
      expect(page).to have_content "こんにちはゲストさん。ログインしてください。"
    end
  end
end
