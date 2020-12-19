# frozen_string_literal: true

RSpec.describe ReservationFramesController, type: :request do
  describe "GET /reservation_frames" do
    subject(:get_reservation_frames) { get "/reservation_frames" }

    let!(:reservation_frame_1) { create(:reservation_frame) }
    let!(:reservation_frame_2) { create(:reservation_frame) }

    it "予約枠一覧ページを表示する" do
      get_reservation_frames

      expect(response).to render_template(:index)
    end

    it "予約枠が一覧できること" do
      get_reservation_frames

      expect(response.body).to include(reservation_frame_1.to_domain_model.tennis_court_name_to_human)
      expect(response.body).to include(reservation_frame_2.to_domain_model.tennis_court_name_to_human)
    end
  end

  describe "POST /reservation_frames/:id/reserve" do
    subject(:reserve) { post "/reservation_frames/#{reservation_frame.id}/reserve" }

    let!(:reservation_frame) { create(:reservation_frame, state: :can_reserve) }

    it "予約ジョブをキューイングする" do
      expect { reserve }.to have_enqueued_job
        .with(reservation_frame.to_domain_model.to_hash)
        .at(Date.tomorrow.beginning_of_day + 7.hours)
    end

    it "予約枠の状態を更新する" do
      reserve

      expect(reservation_frame.reload.state).to eq "will_reserve"
    end

    it "予約枠一覧ページにリダイレクトする" do
      reserve

      expect(response).to redirect_to(reservation_frames_url)
    end
  end
end
