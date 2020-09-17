# frozen_string_literal: true

RSpec.describe Yokohama::TreeEvent, type: :model do
  describe ".build"

  describe "event attributes" do
    using RSpec::Parameterized::TableSyntax

    let!(:timestamp) { "2020-09-06T14:03:10+09:00" }
    let!(:organization) { "yokohama" }
    let!(:park) { "富岡西公園" }
    let!(:date) { "2020-09-13" }
    let!(:time) { "11:00~13:00" }
    let!(:tennis_court) { "テニスコート１" }

    describe "#timestamp" do
      where(:path_str, :result) do
        "/#{timestamp}" | timestamp
        "/#{timestamp}/#{organization}" | timestamp
        "/#{timestamp}/#{organization}/#{park}" | timestamp
        "/#{timestamp}/#{organization}/#{park}/#{date}" | timestamp
        "/#{timestamp}/#{organization}/#{park}/#{date}/#{time}" | timestamp
        "/#{timestamp}/#{organization}/#{park}/#{date}/#{time}/#{tennis_court}" | timestamp
      end

      it do
        path = described_class.build(path_str)
        expect(path.timestamp).to eq result
      end
    end
  end
end
