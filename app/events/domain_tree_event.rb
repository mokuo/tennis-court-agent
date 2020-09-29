# frozen_string_literal: true

class DomainTreeEvent
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::GlobalIdentification

  attribute :path
  attribute :children

  validates :path, presence: true
  validates :children, presence: true

  def publish
    subscribers.each { |s| s.call(self) }
  end

  private

  def subscribers
    default_subscribers + register_subscribers
  end

  def default_subscribers
    [
      ->(event) { EventPersistJob.perform_later(event.path, event.children) }
    ]
  end

  def regsiter_subscribers
    raise NotImplementedError, "You must implement #{self.class}##{__method__}."
  end
end
