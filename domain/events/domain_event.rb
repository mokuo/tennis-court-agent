# frozen_string_literal: true

class DomainEvent
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :availability_check_identifier
  attribute :published_at, :datetime

  validates :availability_check_identifier, presence: true
  validates :published_at, presence: true

  def publish!
    self.published_at = Time.zone.now
    validate!
    domain_event_subscribers.each { |s| s.call(self) }
  end

  def name
    self.class.name
  end

  def contents
    attr = attributes.symbolize_keys
    attr.delete(:availability_check_identifier)
    attr.delete(:published_at)
    attr
  end

  private

  def domain_event_subscribers
    default_subscribers + subscribers
  end

  def default_subscribers
    [
      ->(e) { PersistEventJob.perform_later(e) }
    ]
  end

  def subscribers
    raise NotImplementedError, "You must implement #{self.class}##{__method__}."
  end
end
