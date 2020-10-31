# frozen_string_literal: true

require Rails.root.join("domain/models/domain_event")

class SomeDomainEvent < DomainEvent
  attr_reader :log

  attribute :some_attribute

  private

  def default_subscribers
    [
      ->(e) { @log = ["Default subscriber is called with #{e.name}"] }
    ]
  end

  def subscribers
    [
      ->(e) { @log += ["Subscriber is called with #{e.name}"] }
    ]
  end
end

RSpec.describe DomainEvent do
  describe "#publish!" do
    context "正常系" do
      let!(:time) { Time.current }
      let(:event) do
        SomeDomainEvent.new({ availability_check_identifier: AvailabilityCheckIdentifier.build })
      end

      before { travel_to(time) }

      it "各サブスクライバー（Proc）に自身のインスタンスを渡して call する" do
        event.publish!
        expect(event.log).to eq(
          [
            "Default subscriber is called with SomeDomainEvent",
            "Subscriber is called with SomeDomainEvent"
          ]
        )
      end

      it "イベント発行日時を持つ" do
        event.publish!
        expect(event.published_at).to eq time.floor
      end
    end

    context "バリデーションエラーの時" do
      it "例外を投げる" do
        expect { SomeDomainEvent.new.publish! }.to raise_error(ActiveModel::ValidationError)
      end

      it "サブスクライバーが call されない" do
        event = SomeDomainEvent.new
        begin
          event.publish!
        rescue StandardError
          expect(event.log).to be_nil
        end
      end
    end
  end

  describe "#name" do
    it "イベント名を返す" do
      expect(SomeDomainEvent.new.name).to eq "SomeDomainEvent"
    end
  end
end
