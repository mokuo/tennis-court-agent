# frozen_string_literal: true

class DomainEvent
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :availability_check_identifier
  attribute :published_at, :datetime

  validates :availability_check_identifier, presence: true
  validates :published_at, presence: true

  def publish!
    self.published_at = Time.current
    validate!
    domain_event_subscribers.each { |s| s.call(self) }
  end

  def name
    self.class.name
  end

  def to_hash
    attributes.symbolize_keys.merge(name: self.class.to_s)
  end

  def self.from_hash
    raise NotImplementedError, "You must implement #{self.class}##{__method__}."
  end

  private

  def domain_event_subscribers
    default_subscribers + subscribers
  end

  def default_subscribers
    [
      ->(e) { PersistEventJob.perform_later(e.to_hash) }
    ]
  end

  def subscribers
    raise NotImplementedError, "You must implement #{self.class}##{__method__}."
  end
end
