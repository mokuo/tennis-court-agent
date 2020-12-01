# frozen_string_literal: true

RSpec.describe Api::WakeupController, type: :request do
  describe "POST /api/wakeup" do
    it "return 200 OK" do
      post "/api/wakeup"

      expect(response).to have_http_status(:ok)
    end
  end
end
