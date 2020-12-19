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

  def to_hash
    super.merge(some_attribute: some_attribute)
  end

  def self.from_hash(hash)
    new(
      availability_check_identifier: hash[:availability_check_identifier],
      published_at: hash[:published_at],
      some_attribute: hash[:some_attribute]
    )
  end

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

    # rubocop:disable RSpec/ExampleLength
    it "DomainEvent を永続化する" do
      described_class.persist!(domain_event.to_hash)
      event = described_class.last
      expect(event).to have_attributes(
        availability_check_identifier: identifier,
        name: "TestDomainEvent",
        contents: {
          name: "TestDomainEvent",
          some_attribute: "hoge",
          availability_check_identifier: identifier,
          published_at: time.iso8601(3)
        }.stringify_keys
      )
      expect(event.published_at.floor).to eq time.floor
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe "#to_domain_event" do
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:domain_event) do
      TestDomainEvent.new(
        {
          availability_check_identifier: identifier,
          some_attribute: "hoge",
          published_at: now
        }
      )
    end
    let!(:now) { Time.current }

    before do
      described_class.persist!(domain_event.to_hash)
    end

    it "ドメインイベントを返す" do
      event = described_class.last
      domain_event = event.to_domain_event
      expect(domain_event.published_at.floor).to eq now.floor
      expect(domain_event).to have_attributes(
        name: "TestDomainEvent",
        availability_check_identifier: identifier,
        some_attribute: "hoge"
      )
    end
  end
end
