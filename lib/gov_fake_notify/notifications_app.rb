# frozen_string_literal: true

require 'roda'
require 'json'
require 'gov_fake_notify/commands/send_email_command'
require 'gov_fake_notify/commands/fetch_message_status_command'
require 'gov_fake_notify/commands/fetch_all_messages_status_command'
module GovFakeNotify
  # Serves all notifications resources
  class NotificationsApp < Roda
    plugin :request_headers
    plugin :halt
    plugin :sinatra_helpers
    plugin :json_parser
    route do |r| # rubocop:disable Metrics:BlockLength
      r.is 'email' do
        r.post do
          result = SendEmailCommand.call(request.params, base_url: base_url)
          if result.success?
            result.to_json
          else
            r.halt 422, { message: 'Email failed to send' }.to_json
          end
        end
      end
      r.is String do |id|
        r.get do
          result = FetchMessageStatusCommand.call(id)
          if result.success?
            result.to_json
          else
            r.halt 404, { message: result.errors.join(', ') }.to_json
          end
        end
      end
      r.is do
        r.get do
          result = FetchAllMessagesStatusCommand.call(request.params)
          if result.success?
            result.to_json
          else
            r.halt 404, { message: result.errors.join(', ') }.to_json
          end
        end
      end
    end

    def base_url
      request.url.gsub(%r{/v\d+/.*}, '')
    end
  end
end
