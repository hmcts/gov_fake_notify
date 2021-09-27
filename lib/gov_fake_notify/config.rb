# frozen_string_literal: true

require 'singleton'
require 'fileutils'

# GovFakeNotify module
module GovFakeNotify
  # Central configuration singleton
  class Config
    include Singleton

    attr_accessor :api_key, :smtp_address, :smtp_port, :smtp_user_name, :smtp_password,
                  :smtp_authentication, :smtp_enable_starttls_auto,
                  :base_url, :database_file, :attachments_path, :include_templates,
                  :include_api_keys, :delivery_method
  end

  Config.instance.tap do |c| # rubocop:disable Metrics/BlockLength
    c.api_key = ENV.fetch('GOV_FAKE_NOTIFY_KEY', 'gov-fake-notify-api-key')
    c.smtp_address = ENV.fetch('GOV_FAKE_NOTIFY_SMTP_HOSTNAME', 'localhost')
    c.smtp_port = ENV.fetch('GOV_FAKE_NOTIFY_SMTP_PORT', '1025').to_i
    c.smtp_user_name = ENV['GOV_FAKE_NOTIFY_SMTP_USERNAME']
    c.smtp_password = ENV['GOV_FAKE_NOTIFY_SMTP_PASSWORD']
    c.base_url = ENV.fetch('GOV_FAKE_NOTIFY_BASE_URL', 'http://localhost:8080')
    c.smtp_authentication = nil
    c.smtp_enable_starttls_auto = false
    c.database_file = '/home/devuser/gov_fake_notify_store'
    c.attachments_path = '/home/devuser/gov_fake_notify_attachments'
    c.include_templates = []
    c.include_api_keys = []
    c.delivery_method = :smtp
  end
end
