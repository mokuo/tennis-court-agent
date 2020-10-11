# frozen_string_literal: true

class AvailabilityCheckIdentifier
  def self.build
    Time.current.to_s(:number) # => ex) 20201010104420
  end
end
