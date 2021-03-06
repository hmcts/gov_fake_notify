# frozen_string_literal: true

require 'singleton'
require 'fileutils'
require 'yaml'

# GovFakeNotify module
module GovFakeNotify
  # Central configuration singleton
  class Config
    include Singleton

    attr_accessor :smtp_address, :smtp_port, :smtp_user_name, :smtp_password,
                  :smtp_authentication, :smtp_enable_starttls_auto,
                  :base_url, :database_file, :attachments_path, :include_templates,
                  :include_api_keys, :delivery_method, :port

    def from(hash)
      hash.each_pair do |key, value|
        next unless respond_to?(:"#{key}=")

        send(:"#{key}=", value)
      end
    end
  end

  Config.instance.tap do |c| # rubocop:disable Metrics/BlockLength
    c.smtp_address = ENV.fetch('GOV_FAKE_NOTIFY_SMTP_HOSTNAME', 'localhost')
    c.smtp_port = ENV.fetch('GOV_FAKE_NOTIFY_SMTP_PORT', '1025').to_i
    c.smtp_user_name = ENV['GOV_FAKE_NOTIFY_SMTP_USERNAME']
    c.smtp_password = ENV['GOV_FAKE_NOTIFY_SMTP_PASSWORD']
    c.base_url = ENV.fetch('GOV_FAKE_NOTIFY_BASE_URL', 'http://localhost:8080')
    c.smtp_authentication = nil
    c.smtp_enable_starttls_auto = false
    c.database_file = "#{ENV['HOME']}/.gov_fake_notify/store"
    c.attachments_path = "#{ENV['HOME']}/.gov_fake_notify/attachments"
    c.include_templates = []
    c.include_api_keys = []
    c.delivery_method = 'smtp'
    c.port = 8080
  end
end
