# frozen_string_literal: true

require 'thor'
require 'gov_fake_notify/iodine'
require 'uri'
require 'net/http'
require 'yaml'
module GovFakeNotify
  module Cli
    # Root of all commands
    class Root < Thor
      desc 'start', 'Run fake notify'
      method_option :port, type: :numeric, aliases: '-p', description: 'The port number for the web server (defaults to 8080)'
      method_option :config, type: :string, aliases: '-c', description: 'Configuration specified in a yaml file'
      method_option :smtp_address, type: :string
      method_option :smtp_port, type: :numeric
      method_option :smtp_user_name, type: :string
      method_option :smtp_password, type: :string
      method_option :smtp_authentication, type: :string
      method_option :smtp_enable_starttls_auto, type: :string
      method_option :base_url, type: :string
      method_option :database_file, type: :string
      method_option :attachments_path, type: :string
      method_option :delivery_method, type: :string

      def start
        if options.config
          GovFakeNotify.config do |c|
            c.from(YAML.parse(File.read(options.config)).to_ruby.merge(options.slice(*(options.keys - ['config']))))
          end
        end
        Rack::Server.start app: GovFakeNotify::RootApp, Port: GovFakeNotify.config.port, server: 'iodine'
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
