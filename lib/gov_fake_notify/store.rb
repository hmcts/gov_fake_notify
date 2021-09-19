# frozen_string_literal: true

require 'singleton'
require 'pstore'
module GovFakeNotify
  # A central store for storing all state in the app - uses a basic PStore
  class Store
    def self.instance
      Thread.current[:gov_fake_notify_store] ||= ::PStore.new(GovFakeNotify.config.database_file)
    end
  end
end
