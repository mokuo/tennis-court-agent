# frozen_string_literal: true

RSpec.describe ReservationFrame, type: :model do
  it "has a valid factory" do
    reservation_frame = build(:reservation_frame)
    expect(reservation_frame).to be_valid
  end
end
