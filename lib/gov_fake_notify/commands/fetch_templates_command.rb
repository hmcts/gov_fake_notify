# frozen_string_literal: true

require 'mail'
require 'erb'
require 'tilt'
require 'gov_fake_notify/store'

module GovFakeNotify
  # A service used to fetch all templates
  class FetchTemplatesCommand
    attr_reader :errors

    def self.call(params, **kwargs)
      new(params, **kwargs).call
    end

    def initialize(params, store: Store.instance)
      @params = params
      @store = store
      @errors = []
      @results = []
    end

    def call
      @results = store.transaction { store.roots.select { |k| k =~ /^template-/ } }.map do |key|
        store.transaction { store.fetch(key).slice('id', 'name', 'subject') }
      end
      self
    end

    def success?
      errors.empty?
    end

    def to_json
      JSON.pretty_generate(templates: results)
    end

    private

    attr_reader :params, :store, :results
  end
end
