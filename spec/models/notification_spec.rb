# frozen_string_literal: true

class SlackClientMock
  attr_reader :message

  def send(message)
    @message = message
  end
end

RSpec.describe Notification, type: :model do
  describe "#send" do
    subject(:send_message) { notification.send("メッセージ！！") }

    let!(:slack_client_mock) { SlackClientMock.new }
    let!(:notification) { described_class.new(slack_client_mock) }

    it "メッセージを送ること" do
      send_message
      expect(slack_client_mock.message).to eq "メッセージ！！"
    end
  end
end
