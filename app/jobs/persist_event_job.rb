# frozen_string_literal: true

class PersistEventJob < ApplicationJob
  queue_as :persist_event

  def perform(domain_event_hash)
    domain_event = domain_event_hash[:name].constantize.from_hash(domain_event_hash)
    Event.persist!(domain_event)
  end
end
