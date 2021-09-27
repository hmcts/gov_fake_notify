# frozen_string_literal: true

require 'mail'
require 'erb'
require 'tilt'
require 'gov_fake_notify/store'

module GovFakeNotify
  # A service used to fetch a message status
  class FetchMessageStatusCommand

    attr_reader :errors

    def self.call(id, **kwargs)
      new(id, **kwargs).call
    end

    def initialize(id, store: Store.instance)
      @id = id
      @store = store
      @errors = []
      @message = nil
    end

    def call
      @message = store.transaction { store.fetch("message-#{id}") }
      errors << 'Message not found' and return if message.nil?

      self
    end

    def success?
      errors.empty?
    end

    def to_json
      JSON.pretty_generate(message)
    end

    private

    attr_reader :id, :store, :message
  end
end
