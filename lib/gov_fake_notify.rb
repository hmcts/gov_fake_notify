# frozen_string_literal: true

require 'gov_fake_notify/version'
require 'gov_fake_notify/config'
require 'gov_fake_notify/root_app'
require 'gov_fake_notify/cli'

module GovFakeNotify
  class Error < StandardError; end

  def self.config
    Config.instance.tap do |instance|
      if block_given?
        yield
        configure_mail
      end
      yield instance if block_given?
    end
  end

  def self.configure_mail
    our_config = config
    Mail.defaults do
      delivery_method :smtp, address: our_config.smtp_address, port: our_config.smtp_port
    end
  end
  GovFakeNotify.configure_mail
end
