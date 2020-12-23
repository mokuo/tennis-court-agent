# frozen_string_literal: true

class SlackClient
  def initialize(channel: "#tennis-court", slack_client: Slack::Web::Client.new)
    @client = slack_client
    @channel = channel
  end

  def send(text)
    client.chat_postMessage(channel: channel, text: text)
  end

  def upload_png(file_path:, title:, comment:)
    client.files_upload(
      channels: "#tennis-court",
      as_user: true,
      file: Faraday::UploadIO.new(file_path, "image/png"),
      title: title,
      filename: file_path,
      initial_comment: comment
    )
  end

  private

  attr_reader :client, :channel
end
