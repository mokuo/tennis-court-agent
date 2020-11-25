# frozen_string_literal: true

# NOTE: ローカルで動かす場合も必要
if ENV['CI'].present?
  Capybara.default_driver = :selenium_chrome_headless
  return
end

# NOTE: alpine のコンテナの中で `which chromedriver` してパスを特定した
::Selenium::WebDriver::Chrome::Service.driver_path = "/usr/bin/chromedriver"

# NOTE: Capybara の内部実装の :selenium_chrome_headless を参考にした
Capybara.register_driver :my_selenium_chrome_headless do |app|
  Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.args << "--headless"
    opts.args << "--disable-gpu" if Gem.win_platform?
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.args << "--disable-site-isolation-trials"
    opts.args << "--no-sandbox" # NOTE: いくつかのサイトで見かけたので、付けてみたら動いた
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

Capybara.default_driver = :my_selenium_chrome_headless
