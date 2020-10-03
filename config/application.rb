# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TennisCourtAgent
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Additional config
    config.generators do |g|
      g.assets false
      g.helper false
      g.jbuilder false
      g.test_framework :rspec,
                       view_specs: false,
                       routing_specs: false
    end

    # NOTE: ActiveSupport::TimeWithZone（ActiveRecordも利用）
    # https://railsguides.jp/configuring.html#%E3%82%A4%E3%83%8B%E3%82%B7%E3%83%A3%E3%83%A9%E3%82%A4%E3%82%B6
    config.time_zone = "Tokyo"
    # NOTE: データベースから日付・時刻を取り出した際のタイムゾーン
    # https://railsguides.jp/configuring.html#active-record%E3%82%92%E8%A8%AD%E5%AE%9A%E3%81%99%E3%82%8B
    config.active_record.default_timezone = :local

    # ActiveJob
    config.active_job.queue_adapter = :sidekiq
  end
end
