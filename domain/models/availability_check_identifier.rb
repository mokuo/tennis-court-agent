# frozen_string_literal: true

class AvailabilityCheckIdentifier
  def initialize(identifier)
    @identifier = identifier
  end

  def self.build
    identifier = Time.zone.now.to_s(:number) # => ex) 20201010104420
    new(identifier)
  end

  def to_s
    @identifier
  end
end
