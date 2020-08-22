# frozen_string_literal: true

class Notification
  attr_reader :client

  delegate :send, to: :client

  def initialize(client = SlackClient.new)
    @client = client
  end
end
