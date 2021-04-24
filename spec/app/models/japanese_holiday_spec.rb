# frozen_string_literal: true

RSpec.describe JapaneseHoliday, type: :model do
  it "has a valid data" do
    expect { described_class.new }.not_to raise_error
  end
end
