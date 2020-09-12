# frozen_string_literal: true

class SlackClient
  def initialize(channel: "#tennis-court", slack_client: Slack::Web::Client.new)
    @slack_client = slack_client
    @channel = channel
  end

  def send(text)
    slack_client.chat_postMessage(channel: channel, text: text)
  end

  private

  attr_reader :slack_client, :channel
end
