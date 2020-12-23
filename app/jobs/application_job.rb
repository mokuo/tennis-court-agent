# frozen_string_literal: true

require "capybara/dsl"

class ApplicationJob < ActiveJob::Base
  include Capybara::DSL

  rescue_from(Capybara::ElementNotFound) do |e|
    file_path = "tmp/capybara/error.png"
    save_full_screenshot(file_path)
    slack_client.upload_png(file_path: file_path, title: e.class, comment: e.message)

    raise e
  end

  private

  def slack_client
    SlackClient.new
  end

  def save_full_screenshot(path)
    # NOTE: https://qiita.com/g-fujioka/items/091c400814800f1280ff
    width  = Capybara.page.execute_script("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);")
    height = Capybara.page.execute_script("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);")

    window = Capybara.current_session.driver.browser.manage.window
    window.resize_to(width + 100, height + 100)

    page.save_screenshot path
  end
end
