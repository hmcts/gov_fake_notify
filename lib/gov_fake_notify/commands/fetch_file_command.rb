# frozen_string_literal: true

require 'mail'
require 'erb'
require 'tilt'
require 'gov_fake_notify/store'
require 'gov_fake_notify/attachment_store'

module GovFakeNotify
  # A service used to fetch an attached file
  class FetchFileCommand

    attr_reader :filename, :errors

    def self.call(id, **kwargs)
      new(id, **kwargs).call
    end

    def initialize(id, attachment_store: AttachmentStore.instance)
      @id = id
      @attachment_store = attachment_store
      @errors = []
    end

    def call
      file_data = attachment_store.fetch(id)
      errors << 'File not found' and return self if file_data.nil?

      @filename = file_data['file']
      self
    end

    def success?
      errors.empty?
    end

    private

    attr_reader :id, :attachment_store
  end
end
