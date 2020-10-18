# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id              :bigint           not null, primary key
#  contents        :json
#  name            :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  global_event_id :string(255)      not null
#

require Rails.root.join("domain/models/domain_event")
require Rails.root.join("domain/models/availability_check_identifier")

class TestDomainEvent < DomainEvent
  attribute :some_attribute

  private

  def subscribers
    []
  end
end

RSpec.describe Event, type: :model do
  it "has a valid factory" do
    event = build(:event)
    expect(event.valid?).to be true
  end

  describe ".persist!" do
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:domain_event) do
      TestDomainEvent.new(
        {
          availability_check_identifier: identifier,
          some_attribute: "hoge",
          published_at: time
        }
      )
    end
    let!(:time) { Time.current }

    before { travel_to(time) }

    it "DomainEvent を永続化する" do
      described_class.persist!(domain_event)
      event = described_class.last
      expect(event).to have_attributes(
        availability_check_identifier: identifier,
        name: "TestDomainEvent",
        contents: { some_attribute: "hoge" }.stringify_keys,
        published_at: time.floor
      )
    end
  end
end
