# frozen_string_literal: true

require Rails.root.join("domain/models/availability_check_identifier")
require Rails.root.join("domain/models/yokohama/reservation_frame")

class NotificationServiceMock
  attr_reader :organization_name, :reservation_frames

  def send_availabilities(organization_name, reservation_frames)
    @organization_name = organization_name
    @reservation_frames = reservation_frames
  end
end

RSpec.describe NotificationJob, type: :job do
  describe "#perform" do
    let!(:query_service_mock) { instance_double("QueryService") }
    let!(:notification_service_mock) { NotificationServiceMock.new }
    let!(:identifier) { AvailabilityCheckIdentifier.build }
    let!(:reservation_frame) do
      Yokohama::ReservationFrame.new(
        park_name: "公園１",
        tennis_court_name: "テニスコート１",
        start_date_time: Time.current,
        end_date_time: Time.current.next_day,
        now: true
      )
    end
    let!(:job) { described_class.new }

    before do
      allow(job).to receive(:query_service).and_return(query_service_mock)
      allow(job).to receive(:notification_service).and_return(notification_service_mock)
    end

    # rubocop:disable RSpec/MultipleExpectations
    it "空き状況を通知する" do
      expect(query_service_mock).to receive(:reservation_frames).with(identifier).and_return([reservation_frame])

      job.perform(identifier)

      expect(notification_service_mock).to have_attributes(organization_name: "横浜市")
      expect(notification_service_mock.reservation_frames.first.eql?(reservation_frame)).to be true
    end
    # rubocop:enable RSpec/MultipleExpectations
  end
end
