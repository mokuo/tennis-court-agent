# frozen_string_literal: true

require "capybara/dsl"
require Rails.root.join("domain/services/notification_service")

class ReservationJob < ApplicationJob
  queue_as :reservation

  include Capybara::DSL

  rescue_from(Capybara::ElementNotFound) do |e|
    file_path = "tmp/capybara/error.png"
    save_full_screenshot(file_path)
    slack_client.upload_png(file_path: file_path, title: e.class, comment: e.message)

    raise e
  end

  def perform(reservation_frame_hash)
    rf = Yokohama::ReservationFrame.from_hash(reservation_frame_hash)
    result = service.reserve(rf)

    reservation_frame = ReservationFrame.find(rf.id)
    if result
      reservation_frame.update!(state: :reserved)
    else
      reservation_frame.update!(state: :failed)
    end
  end

  private

  def service
    YokohamaService.new
  end

  def slack_client
    SlackClient.new
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
