# frozen_string_literal: true

class QueryService
  def reservation_frames(identifier)
    events = Event.where(
      availability_check_identifier: identifier,
      name: "Yokohama::ReservationStatusChecked"
    )
    domain_events = events.map(&:to_domain_event)
    domain_events.map(&:reservation_frame)
  end
end
