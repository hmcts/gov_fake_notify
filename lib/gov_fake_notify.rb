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
        yield instance
        configure_mail
        configure_templates
        configure_api_keys
      end
    end
  end

  def self.configure_mail
    our_config = config
    Mail.defaults do
      case our_config.delivery_method
      when 'smtp'
        delivery_method :smtp, address: our_config.smtp_address, port: our_config.smtp_port
      when 'test'
        delivery_method :test
      end
    end
  end

  def self.configure_templates(store: Store.instance)
    config.include_templates.each do |t|
      template = t.transform_keys(&:to_s)
      next if store.transaction { store.root?("template-#{template['id']}") }

      store.transaction { store["template-#{template['id']}"] = template.dup }
    end
  end

  def self.configure_api_keys(store: Store.instance)
    config.include_api_keys.each do |k|
      api_key = k.transform_keys(&:to_s)
      next if store.transaction { store.root?("apikey-#{api_key['key']}") }

      store.transaction do
        key = api_key.dup
        secret_token = key['key']
        key['service_id'] = secret_token[-73..-38]
        key['secret_token'] = secret_token[-36..-1]
        store["apikey-#{api_key['key']}"] = key
      end
    end
  end

  def self.init
    Config.instance # Pre load
    FileUtils.mkdir_p GovFakeNotify.config.attachments_path
    FileUtils.mkdir_p File.dirname(GovFakeNotify.config.database_file)
    GovFakeNotify.configure_mail
    GovFakeNotify.configure_templates
    GovFakeNotify.configure_api_keys
  end

  def self.reset!
    Store.clear_messages!
  end
end

GovFakeNotify.init
