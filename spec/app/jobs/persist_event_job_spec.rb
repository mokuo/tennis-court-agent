# frozen_string_literal: true

require Rails.root.join("domain/models/availability_check_identifier")
require Rails.root.join("domain/events/domain_event")

class TestDomainEvent < DomainEvent
  attribute :some_attribute

  private

  def subscribers
    []
  end
end

RSpec.describe PersistEventJob, type: :job do
  describe "#perform" do
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:domain_event) do
      TestDomainEvent.new(
        {
          availability_check_identifier: identifier,
          published_at: Time.zone.now,
          some_attribute: "hoge"
        }
      )
    end

    it "ドメインイベントを永続化する" do
      expect { described_class.new.perform(domain_event) }.to change(Event, :count).from(0).to(1)
    end
  end
end
