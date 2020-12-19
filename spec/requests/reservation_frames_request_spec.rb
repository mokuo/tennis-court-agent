# frozen_string_literal: true

RSpec.describe "ReservationFrames", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/reservation_frames/index"
      expect(response).to have_http_status(:success)
    end
  end
end
