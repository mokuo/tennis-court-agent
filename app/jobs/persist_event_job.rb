# frozen_string_literal: true

class PersistEventJob < ApplicationJob
  queue_as :persist_event

  def perform(domain_event_hash)
    Event.persist!(domain_event_hash)
  end
end
