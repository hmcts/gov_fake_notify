# frozen_string_literal: true

require 'gov_fake_notify/store'
module GovFakeNotify
  # A service used internally to create a new template from the API / command line
  class CreateTemplateCommand
    def self.call(params)
      # do nothing yet
      new(params).call
    end

    def initialize(params, store: Store.instance)
      @params = params
      @store = store
    end

    def call
      store.transaction { store["template-#{params['id']}"] = params }

      self
    end

    def success?
      true
    end

    def to_json(*_args)
      JSON.generate({ success: true })
    end

    private

    attr_reader :params, :store
  end
end
