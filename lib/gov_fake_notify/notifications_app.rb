# frozen_string_literal: true

require 'roda'
require 'json'
require 'gov_fake_notify/commands/send_email_command'
module GovFakeNotify
  # Serves all notifications resources
  class NotificationsApp < Roda
    plugin :request_headers
    plugin :halt
    plugin :sinatra_helpers
    plugin :json_parser
    route do |r|
      r.is 'email' do
        r.post do
          result = SendEmailCommand.call(request.params)
          if result.success?
            result.to_json
          else
            r.halt 422, { message: 'Email failed to send' }.to_json
          end
        end
      end
    end
  end
end
