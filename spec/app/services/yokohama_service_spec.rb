# frozen_string_literal: true

require Rails.root.join("domain/models/available_date")
require Rails.root.join("domain/models/availability_check_identifier")
require Rails.root.join("domain/models/yokohama/reservation_frame")
require Rails.root.join("domain/models/yokohama/availability_check_started")
require Rails.root.join("domain/models/yokohama/available_dates_found")
require Rails.root.join("domain/models/yokohama/available_dates_filtered")
require Rails.root.join("domain/models/yokohama/reservation_frames_found")
require Rails.root.join("domain/models/yokohama/reservation_status_checked")

RSpec.describe YokohamaService, type: :job do
  describe "start_availability_check" do
    subject(:start_availability_check) { described_class.new.start_availability_check }

    let!(:now) { Time.current }
    let!(:identifier) { now.to_s(:number) }

    before { travel_to(now) }

    it "availability_check_identifier を発行する" do
      expect { start_availability_check }.to change(AvailabilityCheck, :count).from(0).to(1)
    end

    it "ドメインイベントを発行し、永続化される" do
      start_availability_check

      expect(PersistEventJob).to have_been_enqueued.with(
        {
          availability_check_identifier: identifier,
          name: "Yokohama::AvailabilityCheckStarted",
          park_names: %w[富岡西公園 三ツ沢公園 新杉田公園],
          published_at: now
        }
      )
    end

    # rubocop:disable RSpec/MultipleExpectations
    it "次のジョブがキューに入る" do
      start_availability_check

      expect(Yokohama::AvailableDatesJob).to have_been_enqueued.with(identifier, "富岡西公園").once
      expect(Yokohama::AvailableDatesJob).to have_been_enqueued.with(identifier, "三ツ沢公園").once
      expect(Yokohama::AvailableDatesJob).to have_been_enqueued.with(identifier, "新杉田公園").once
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  describe "#available_dates" do
    subject(:available_dates) { yokohama_service.available_dates(identifier, "公園１") }

    let!(:yokohama_service) { described_class.new(mock_scraping_service) }
    let!(:mock_scraping_service) { instance_double("Yokohama::ScrapingService") }
    let!(:available_date) { AvailableDate.new(Date.current) }
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:now) { Time.current }

    before do
      travel_to(now)
      allow(mock_scraping_service).to receive(:available_dates).and_return([available_date])
    end

    it "利用可能日を取得する" do
      expect(mock_scraping_service).to receive(:available_dates).with("公園１").and_return([available_date])

      available_dates
    end

    it "ドメインイベントを発行し、永続化される" do
      available_dates

      expect(PersistEventJob).to have_been_enqueued.with(
        {
          availability_check_identifier: identifier,
          park_name: "公園１",
          available_dates: [available_date.to_date],
          name: "Yokohama::AvailableDatesFound",
          published_at: now
        }
      )
    end

    it "次のジョブがキューに入る" do
      available_dates

      expect(Yokohama::FilterAvailableDatesJob).to have_been_enqueued.with(identifier, "公園１", [available_date.to_date])
    end
  end

  describe "#filter_available_dates" do
    subject(:filter_available_dates) { described_class.new.filter_available_dates(identifier, "公園１", available_dates) }

    let!(:holiday) { Date.new(2020, 10, 11) }
    let!(:weekday) { Date.new(2020, 10, 12) }
    let!(:available_dates) { [AvailableDate.new(holiday), AvailableDate.new(weekday)] }
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:now) { Time.current }

    before { travel_to(now) }

    it "利用可能日を休日に絞り、ドメインイベントを発行する" do
      filter_available_dates

      expect(PersistEventJob).to have_been_enqueued.with(
        {
          availability_check_identifier: identifier,
          park_name: "公園１",
          available_dates: [holiday],
          name: "Yokohama::AvailableDatesFiltered",
          published_at: now
        }
      )
    end

    it "次のジョブがキューに入る" do
      filter_available_dates

      expect(Yokohama::ReservationFramesJob).to have_been_enqueued.with(identifier, "公園１", holiday)
    end
  end

  describe "#reservation_frames" do
    subject(:reservation_frames) do
      described_class.new(mock_scraping_service).reservation_frames(identifier, "公園１", AvailableDate.new(date))
    end

    let!(:date) { Date.current }
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:now) { Time.current }
    let!(:mock_scraping_service) { instance_double("Yokohama::ScrapingService") }
    let!(:reservation_frame) do
      Yokohama::ReservationFrame.new(
        tennis_court_name: "テニスコート１",
        start_date_time: now.next_day,
        end_date_time: now.next_day.change(hour: now.hour + 2)
      )
    end

    before do
      travel_to(now)
      allow(mock_scraping_service).to receive(:reservation_frames).and_return([reservation_frame])
    end

    it "予約枠を取得する" do
      expect(mock_scraping_service).to receive(:reservation_frames).with("公園１", date)

      reservation_frames
    end

    it "ドメインイベントを発行し、永続化する" do
      reservation_frames

      expect(PersistEventJob).to have_been_enqueued.with(
        availability_check_identifier: identifier,
        park_name: "公園１",
        available_date: date,
        reservation_frames: [reservation_frame.to_hash],
        name: "Yokohama::ReservationFramesFound",
        published_at: now
      )
    end

    it "次のジョブがキューに入る" do
      reservation_frames

      expect(Yokohama::ReservationStatusJob).to have_been_enqueued.with(identifier, "公園１", reservation_frame.to_hash)
    end
  end

  describe "#reservation_status" do
    subject(:reservation_status) do
      described_class.new(mock_scraping_service).reservation_status(identifier, "公園１", reservation_frame)
    end

    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:now) { Time.current }
    let!(:mock_scraping_service) { instance_double("Yokohama::ScrapingService") }
    let!(:reservation_frame) do
      Yokohama::ReservationFrame.new(
        park_name: "公園１",
        tennis_court_name: "テニスコート１",
        start_date_time: now.next_day,
        end_date_time: now.next_day.change(hour: now.hour + 2)
      )
    end

    before do
      travel_to(now)
      allow(mock_scraping_service).to receive(:reservation_status).and_return(true)
    end

    it "今すぐ予約できるかどうかを確認する" do
      expect(mock_scraping_service).to receive(:reservation_status).with("公園１", reservation_frame)

      reservation_status
    end

    it "ドメインイベントを発行し、永続化する" do
      reservation_status
      reservation_frame.now = true

      expect(PersistEventJob).to have_been_enqueued.with(
        availability_check_identifier: identifier,
        reservation_frame: reservation_frame.to_hash,
        park_name: "公園１",
        name: "Yokohama::ReservationStatusChecked",
        published_at: now
      )
    end

    it "次のジョブがキューに入る" do
      reservation_status

      expect(Yokohama::InspectEventsJob).to have_been_enqueued.with(identifier)
    end
  end

  describe "#inspect_events" do
    subject(:inspect_events) { described_class.new.inspect_events(identifier) }

    context "全イベントが完了している時" do
      let!(:identifier) { AvailabilityCheckIdentifier.build }

      before do
        availability_check_started = Yokohama::AvailabilityCheckStarted.new(
          availability_check_identifier: identifier,
          published_at: Time.current,
          park_names: ["公園１"]
        )
        available_dates_found = Yokohama::AvailableDatesFound.new(
          availability_check_identifier: identifier,
          published_at: Time.current,
          park_name: "公園１",
          available_dates: [AvailableDate.new(Date.tomorrow)]
        )
        available_dates_filtered = Yokohama::AvailableDatesFiltered.new(
          availability_check_identifier: identifier,
          published_at: Time.current,
          park_name: "公園１",
          available_dates: [AvailableDate.new(Date.tomorrow)]
        )
        reservation_frames_found = Yokohama::ReservationFramesFound.new(
          availability_check_identifier: identifier,
          published_at: Time.current,
          park_name: "公園１",
          available_date: AvailableDate.new(Date.tomorrow),
          reservation_frames: [
            Yokohama::ReservationFrame.new(
              park_name: "公園１",
              tennis_court_name: "テニスコート１",
              start_date_time: Time.current,
              end_date_time: Time.current.next_day
            )
          ]
        )
        reservation_status_checked = Yokohama::ReservationStatusChecked.new(
          availability_check_identifier: identifier,
          published_at: Time.current,
          park_name: "公園１",
          reservation_frame: Yokohama::ReservationFrame.new(
            park_name: "公園１",
            tennis_court_name: "テニスコート１",
            start_date_time: Time.current,
            end_date_time: Time.current.next_day,
            now: true
          )
        )
        Event.persist!(availability_check_started.to_hash)
        Event.persist!(available_dates_found.to_hash)
        Event.persist!(available_dates_filtered.to_hash)
        Event.persist!(reservation_frames_found.to_hash)
        Event.persist!(reservation_status_checked.to_hash)
      end

      context "既に完了確認済みのとき" do
        before do
          AvailabilityCheck.create!(identifier: identifier, state: :finished)
        end

        it "ドメインイベントを発行せず return する" do
          expect(PersistEventJob).not_to have_been_enqueued
        end
      end

      context "まだ完了確認済みではない時" do
        let!(:availability_check) { AvailabilityCheck.create!(identifier: identifier, state: :started) }

        it "状態を完了済みにする" do
          inspect_events

          expect(availability_check.reload.state).to eq "finished"
        end

        it "ドメインイベントを発行し、永続化する" do
          now = Time.current
          travel_to(now)
          inspect_events

          expect(PersistEventJob).to have_been_enqueued.with(
            name: "Yokohama::AvailabilityCheckFinished",
            availability_check_identifier: identifier,
            published_at: now
          )
        end

        it "次のジョブがキューに入る" do
          inspect_events

          expect(NotificationJob).to have_been_enqueued.with(identifier)
          expect(CreateReservationFramesJob).to have_been_enqueued.with(identifier)
        end
      end
    end

    context "全イベントが完了していない時" do
      let!(:identifier) { AvailabilityCheckIdentifier.build }
      let!(:availability_check) { AvailabilityCheck.create!(identifier: identifier, state: :started) }

      before do
        availability_check_started = Yokohama::AvailabilityCheckStarted.new(
          availability_check_identifier: identifier,
          published_at: Time.current,
          park_names: ["公園１"]
        )
        available_dates_found = Yokohama::AvailableDatesFound.new(
          availability_check_identifier: identifier,
          published_at: Time.current,
          park_name: "公園１",
          available_dates: [AvailableDate.new(Date.tomorrow)]
        )
        available_dates_filtered = Yokohama::AvailableDatesFiltered.new(
          availability_check_identifier: identifier,
          published_at: Time.current,
          park_name: "公園１",
          available_dates: [AvailableDate.new(Date.tomorrow)]
        )
        reservation_frames_found = Yokohama::ReservationFramesFound.new(
          availability_check_identifier: identifier,
          published_at: Time.current,
          park_name: "公園１",
          available_date: AvailableDate.new(Date.tomorrow),
          reservation_frames: [
            Yokohama::ReservationFrame.new(
              park_name: "公園１",
              tennis_court_name: "テニスコート１",
              start_date_time: Time.current,
              end_date_time: Time.current.next_day
            ),
            Yokohama::ReservationFrame.new(
              park_name: "公園１",
              tennis_court_name: "テニスコート２",
              start_date_time: Time.current,
              end_date_time: Time.current.next_day
            )
          ]
        )
        reservation_status_checked = Yokohama::ReservationStatusChecked.new(
          availability_check_identifier: identifier,
          published_at: Time.current,
          park_name: "公園１",
          reservation_frame: Yokohama::ReservationFrame.new(
            park_name: "公園１",
            tennis_court_name: "テニスコート１",
            start_date_time: Time.current,
            end_date_time: Time.current.next_day,
            now: true
          )
        )
        Event.persist!(availability_check_started.to_hash)
        Event.persist!(available_dates_found.to_hash)
        Event.persist!(available_dates_filtered.to_hash)
        Event.persist!(reservation_frames_found.to_hash)
        Event.persist!(reservation_status_checked.to_hash)
      end

      it "状態を更新しない" do
        inspect_events

        expect(availability_check.reload.state).to eq "started"
      end

      it "ドメインイベントを発行しない" do
        inspect_events

        expect(PersistEventJob).not_to have_been_enqueued
      end
    end
  end

  describe "#reserve" do
    let!(:mock_scraping_service) { instance_double("Yokohama::ScrapingService") }
    let(:reservation_frame) do
      Yokohama::ReservationFrame.new(
        park_name: "A公園",
        tennis_court_name: "A公園 テニスコート１",
        start_date_time: Time.current,
        end_date_time: Time.current.next_day
      )
    end

    context "予約に成功する時" do
      it "予約処理を行い、true を返す" do
        allow(mock_scraping_service).to receive(:reserve).and_return(true)

        expect(mock_scraping_service).to receive(:reserve).with(reservation_frame, waiting: false).once

        service = described_class.new(mock_scraping_service)
        expect(service.reserve(reservation_frame, waiting: false)).to be true
      end
    end

    context "予約に失敗する時" do
      it "予約処理を行い、false を返す" do
        allow(mock_scraping_service).to receive(:reserve).and_return(false)

        expect(mock_scraping_service).to receive(:reserve).with(reservation_frame, waiting: false).once

        service = described_class.new(mock_scraping_service)
        expect(service.reserve(reservation_frame, waiting: false)).to be false
      end
    end
  end
end
