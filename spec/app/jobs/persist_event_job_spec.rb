# frozen_string_literal: true

require Rails.root.join("domain/models/availability_check_identifier")
require Rails.root.join("domain/models/domain_event")

class TestDomainEvent < DomainEvent
  attribute :some_attribute, :string

  def subscribers
    []
  end

  def to_hash
    attributes.symbolize_keys.merge(name: self.class.to_s)
  end

  def self.from_hash(hash)
    new(
      availability_check_identifier: hash[:availability_check_identifier],
      published_at: hash[:availability_check_identifier],
      some_attribute: hash[:some_attribute]
    )
  end
end

RSpec.describe PersistEventJob, type: :job do
  describe "#perform" do
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:test_domain_event) do
      TestDomainEvent.new(
        availability_check_identifier: identifier,
        published_at: Time.current,
        some_attribute: "hoge"
      )
    end

    it "ドメインイベントを永続化する" do
      expect { described_class.new.perform(test_domain_event.to_hash) }.to change(Event, :count).from(0).to(1)
    end
  end
end
