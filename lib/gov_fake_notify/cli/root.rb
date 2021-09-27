# frozen_string_literal: true

require 'thor'
require 'gov_fake_notify/iodine'
require 'uri'
require 'net/http'
module GovFakeNotify
  module Cli
    # Root of all commands
    class Root < Thor
      desc 'start', 'Run fake notify'
      method_option :port, type: :numeric, default: 8080

      def start
        Rack::Server.start app: GovFakeNotify::RootApp, Port: options.port, server: 'iodine'
      end

      desc 'create-template', 'Create a template'
      method_option :template_id, type: :string, required: true
      method_option :path, type: :string, required: true
      method_option :name, type: :string, required: true
      method_option :subject, type: :string, required: true
      def create_template
        data = {
          id: options.template_id,
          message: File.read(options.path),
          name: options.name,
          subject: options.subject
        }
        res = Net::HTTP.post(URI("#{GovFakeNotify.config.base_url}/control/templates"), JSON.generate(data),
                             { 'Content-Type' => 'application/json', 'Accept' => 'application/json' })
        puts res.body
      end
    end
  end
end
