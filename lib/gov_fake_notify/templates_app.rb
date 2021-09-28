# frozen_string_literal: true

require 'roda'
require 'json'
require 'gov_fake_notify/commands/fetch_templates_command'
require 'gov_fake_notify/current_service'

module GovFakeNotify
  # A group of endpoints for the templates
  class TemplatesApp < Roda
    include CurrentService
    plugin :request_headers
    plugin :halt
    plugin :sinatra_helpers
    plugin :json_parser
    route do |r|
      unless current_service
        r.halt 403, { 'Content-Type' => 'application/json' }, { message: 'Invalid or missing token' }.to_json
      end
      r.is do
        r.get do
          result = FetchTemplatesCommand.call(request.params)
          if result.success?
            result.to_json
          else
            r.halt 404, { message: result.errors.join(', ') }.to_json
          end
        end
      end
    end
  end
end
