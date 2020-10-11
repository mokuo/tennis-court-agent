# frozen_string_literal: true

require Rails.root.join("domain/models/availability_check_identifier")

RSpec.describe AvailabilityCheckIdentifier do
  describe ".build" do
    subject(:build) { described_class.build }

    let!(:now) { Time.current }

    before { travel_to(now) }

    it "%Y%m%d%H%M%S フォーマットで identifier を生成する" do
      expect(build).to eq now.to_s(:number)
    end
  end
end
