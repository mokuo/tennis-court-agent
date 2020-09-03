# frozen_string_literal: true

module Yokohama
  class TreeEventSubscribers
    def self.all
      [
        {
          event: AvailableDatesFound,
          subscribers: [
            ->(event) { ReservationFramesExecuter.start!(event) },
            ->(event) { DomainEventPersister.persist!(event) }
          ]
        },
        {
          event: ReservationFramesFound,
          subscribers: [
            ->(event) { ReservationStatusExecuter.start!(event) },
            ->(event) { ReservationFramesExecuter.check_all!(event) },
            ->(event) { DomainEventPersister.persist!(event) }
          ]
        },
        {
          event: ReservationStatusChecked,
          subscribers: [
            ->(event) { ReservationStatusExecuter.check_all!(event) },
            ->(event) { DomainEventPersister.persist!(event) }
          ]
        },
        {
          event: AllReservationFramesFound,
          subscribers: [
            ->(event) { NotificationExecuter.run!(event) },
            ->(event) { DomainEventPersister.persist!(event) }
          ]
        }
      ]
    end
  end
end
