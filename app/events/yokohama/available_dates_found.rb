# frozen_string_literal: true

module Yokohama
  class AvailableDatesFound < DomainEvent
    attribute :root_event_id, :integer
    attribute :park_name, :string
    attribute :available_dates, array: :date
  end
end
