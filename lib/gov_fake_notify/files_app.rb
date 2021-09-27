# frozen_string_literal: true

require 'roda'
require 'json'
require 'gov_fake_notify/commands/send_email_command'
require 'gov_fake_notify/commands/fetch_file_command'
require 'tilt'
module GovFakeNotify
  # Serves all attachment files
  class FilesApp < Roda
    plugin :request_headers
    plugin :halt
    plugin :sinatra_helpers
    route do |r|
      r.is 'download', String do |id|
        Tilt.new(File.absolute_path('../views/files/download.html.erb', __dir__)).render(nil, service_name: 'Employment Tribunals', service_email: 'et@test.com', id: id)
      end
      r.is 'confirm', String do |id|
        Tilt.new(File.absolute_path('../views/files/confirm.html.erb', __dir__)).render(nil, service_name: 'Employment Tribunals', service_email: 'et@test.com', id: id)
      end
      r.is String do |id|
        r.get do
          result = FetchFileCommand.call(id)
          if result.success?
            attachment result.filename
            send_file result.filename
          else
            r.halt 422, { message: 'Email failed to send' }.to_json
          end
        end
      end
    end

    def base_url
      request.url.gsub(%r{/v\d+/.*}, '')
    end
  end
end
