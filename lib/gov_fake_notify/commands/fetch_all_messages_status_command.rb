# frozen_string_literal: true

require 'mail'
require 'erb'
require 'tilt'
require 'gov_fake_notify/store'

module GovFakeNotify
  # A service used to fetch all message statuses
  class FetchAllMessagesStatusCommand

    attr_reader :errors

    def self.call(params, **kwargs)
      new(params, **kwargs).call
    end

    def initialize(params, store: Store.instance)
      @params = params
      @store = store
      @errors = []
      @messages = []
    end

    def call
      message_keys = store.transaction { store.roots.select { |k| k =~ /^message-/ } }
      @messages = store.transaction { message_keys.map { |key| store.fetch(key) } }

      self
    end

    def success?
      errors.empty?
    end

    def to_json
      # We do not support links yet
      JSON.pretty_generate(notifications: messages, links: [])
    end

    private

    attr_reader :params, :store, :messages
  end
end
