# frozen_string_literal: true

RSpec.describe ReservationFramesController, type: :request do
  describe "GET /reservation_frames" do
    subject(:get_reservation_frames) { get "/reservation_frames" }

    let!(:reservation_frame_1) { create(:reservation_frame) }
    let!(:reservation_frame_2) { create(:reservation_frame) }
    let!(:availability_check) { create(:availability_check, state: :finished) }

    it "予約枠一覧ページを表示する" do
      get_reservation_frames

      expect(response).to render_template(:index)
    end

    it "予約枠が一覧できること" do
      get_reservation_frames

      expect(response.body).to include(reservation_frame_1.to_domain_model.tennis_court_name_to_human)
      expect(response.body).to include(reservation_frame_2.to_domain_model.tennis_court_name_to_human)
    end

    it "空き状況の取得日時を表示すること" do
      get_reservation_frames

      expect(response.body).to include("#{availability_check.created_at.strftime('%Y-%m-%d %H:%M:%S')} 時点")
    end
  end

  describe "POST /reservation_frames/:id/reserve" do
    subject(:reserve) { post "/reservation_frames/#{reservation_frame.id}/reserve" }

    context "翌朝に予約可能な場合" do
      let!(:reservation_frame) { create(:reservation_frame, state: :can_reserve, now: false) }

      it "予約ジョブをキューイングする" do
        rf = reservation_frame.to_domain_model

        expect { reserve }.to have_enqueued_job
          .with(rf.to_hash)
          .at(Date.tomorrow.beginning_of_day + rf.opening_hour.hours - 1.minute)
      end

      it "予約枠の状態を更新する" do
        reserve

        expect(reservation_frame.reload.state).to eq "will_reserve"
      end

      it "flash メッセージを表示する" do
        reserve

        expect(flash[:success]).to include("予約処理を開始しました。")
      end

      it "予約枠一覧ページにリダイレクトする" do
        reserve

        expect(response).to redirect_to(reservation_frames_url)
      end
    end

    context "今すぐ予約可能な場合" do
      let!(:reservation_frame) { create(:reservation_frame, state: :can_reserve, now: true) }

      it "予約ジョブをキューイングする" do
        expect { reserve }.to have_enqueued_job
          .with(reservation_frame.to_domain_model.to_hash)
          # ref: https://relishapp.com/rspec/rspec-rails/docs/job-specs/job-spec#specify-that-job-was-enqueued-with-no-wait
          .at(:no_wait)
      end

      it "予約枠の状態を更新する" do
        reserve

        expect(reservation_frame.reload.state).to eq "reserving"
      end

      it "flash メッセージを表示する" do
        reserve

        expect(flash[:success]).to include("予約処理を開始しました。")
      end

      it "予約枠一覧ページにリダイレクトする" do
        reserve

        expect(response).to redirect_to(reservation_frames_url)
      end
    end
  end
end
