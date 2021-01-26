# frozen_string_literal: true

require "capybara/dsl"
require Rails.root.join("domain/services/reservation_frames_service")

class NotificationService
  include Capybara::DSL

  def initialize(client = SlackClient.new)
    @client = client
  end

  def send_availabilities(organization_name, reservation_frames)
    message = build_message(organization_name, reservation_frames)
    client.send(message)
  end

  def send_message(message)
    client.send(message)
  end

  def send_screenshot(title, comment)
    file_path = "tmp/capybara/#{SecureRandom.uuid}.png"
    save_full_screenshot(file_path)
    client.upload_png(file_path: file_path, title: title, comment: comment)
  end

  private

  attr_reader :client

  def build_message(organization_name, reservation_frames)
    return "#{organization_name}のテニスコートの空き予約枠はありませんでした。" if reservation_frames.blank?

    msg = "#{organization_name}のテニスコートの空き状況です。\n\n"

    rfs = sort_reservation_frames(reservation_frames)
    rfs.each do |reservation_frame|
      msg += "- #{reservation_frame.to_human}\n"
    end

    msg
  end

  def sort_reservation_frames(reservation_frames)
    ReservationFramesService.new.sort(reservation_frames)
  end

  def save_full_screenshot(path)
    # NOTE: https://qiita.com/g-fujioka/items/091c400814800f1280ff
    # rubocop:disable Layout/LineLength
    width  = Capybara.page.execute_script("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);")
    height = Capybara.page.execute_script("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);")
    # rubocop:enable Layout/LineLength

    window = Capybara.current_session.driver.browser.manage.window
    window.resize_to(width, height)

    page.save_screenshot path
  end
end
