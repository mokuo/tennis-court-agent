# frozen_string_literal: true

require "capybara/dsl"
require Rails.root.join("domain/services/notification_service")
require Rails.root.join("domain/models/yokohama/reservation_frame")

class ReservationJob < ApplicationJob
  queue_as :reservation
  sidekiq_options retry: 5 # ref: https://github.com/mperham/sidekiq/wiki/Advanced-Options#workers

  delegate :send_message, to: :notification_service

  include Capybara::DSL

  rescue_from(Capybara::ElementNotFound) do |exception|
    ReservationJob.new.send_error_screenshot(exception)

    raise exception
    # TODO: reservation_frame の state を failed にしたい
  end

  # rubocop:disable Metrics/MethodLength
  def perform(reservation_frame_hash, waiting: false)
    # HACK: ごっそり YokohamaService に移す？
    rf = Yokohama::ReservationFrame.from_hash(reservation_frame_hash)
    notification_service.send_message("`#{rf.to_human}`の予約を開始します。")
    result = service.reserve(rf, waiting: waiting)

    reservation_frame = ReservationFrame.find(rf.id)
    if result
      reservation_frame.update!(state: :reserved)
      notification_service.send_message("`#{rf.to_human}`の予約に成功しました！")
    else
      reservation_frame.update!(state: :failed)
      notification_service.send_message("`#{rf.to_human}`の予約に失敗しました。")
    end
  end
  # rubocop:enable Metrics/MethodLength

  # HACK: NotificationService に移す
  def send_error_screenshot(error)
    file_path = "tmp/capybara/error_#{SecureRandom.uuid}.png"
    save_full_screenshot(file_path)
    slack_client.upload_png(file_path: file_path, title: error.message, comment: error.class)
  end

  private

  def service
    YokohamaService.new
  end

  # HACK: NotificationService に移す
  def slack_client
    SlackClient.new
  end

  def notification_service
    NotificationService.new
  end

  def save_full_screenshot(path)
    # NOTE: https://qiita.com/g-fujioka/items/091c400814800f1280ff
    # rubocop:disable Layout/LineLength
    width  = Capybara.page.execute_script("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);")
    height = Capybara.page.execute_script("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);")
    # rubocop:enable Layout/LineLength

    window = Capybara.current_session.driver.browser.manage.window
    window.resize_to(width + 100, height + 100)

    page.save_screenshot path
  end
end
