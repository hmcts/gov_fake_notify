# frozen_string_literal: true

require 'singleton'
require 'pstore'
module GovFakeNotify
  # A central store for storing all state in the app - uses a basic PStore
  class Store
    def self.instance
      Thread.current[:gov_fake_notify_store] ||= ::PStore.new(GovFakeNotify.config.database_file)
    end

    def self.clear_messages!
      instance.transaction do
        instance.roots.each do |key|
          next unless key =~ /^message-/

          instance.delete(key)
        end
      end
      clear_attachments!
    end

    def self.clear_attachments!(config: Config.instance)
      FileUtils.rm_rf File.join(config.attachments_path, '.')
    end
  end
end
