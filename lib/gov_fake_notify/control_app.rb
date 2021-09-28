# frozen_string_literal: true

require 'roda'
require 'json'
require 'gov_fake_notify/commands/create_template_command'
module GovFakeNotify
  # A group of endpoints dedicated to controlling the app from the command line or API - for development and test only
  class ControlApp < Roda
    plugin :request_headers
    plugin :halt
    plugin :sinatra_helpers
    plugin :json_parser
    route do |r|
      r.is 'reset' do
        r.post do
          GovFakeNotify.reset!
        end
      end
      r.is 'templates' do
        r.post do
          result = CreateTemplateCommand.call(request.params)
          if result.success?
            result.to_json
          else
            r.halt 422, { message: 'Command failed' }.to_json
          end
        end
      end
    end
  end
end
