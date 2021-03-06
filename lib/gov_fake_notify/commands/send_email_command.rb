# frozen_string_literal: true

require 'mail'
require 'erb'
require 'tilt'
require 'gov_fake_notify/store'
require 'gov_fake_notify/attachment_store'

module GovFakeNotify
  # A service used when the sending of an email is requested
  class SendEmailCommand # rubocop:disable Metrics/ClassLength
    def self.call(params, **kwargs)
      # do nothing yet
      new(params, **kwargs).call
    end

    def initialize(params, base_url:, service:, store: Store.instance, attachment_store: AttachmentStore.instance)
      @params = params.dup
      @store = store
      @attachment_store = attachment_store
      @base_url = base_url
      @service = service
    end

    def call
      template_data = store.transaction { store["template-#{params['template_id']}"] }
      send_email_from_template(template_data)
      persist_status(template_data)
      self
    end

    def success?
      true
    end

    def to_json(*_args) # rubocop:disable Metrics/MethodLength
      ::JSON.generate({
                        "id": id,
                        "reference": 'STRING',
                        "content": {
                          "body": message_body,
                          "from_number": 'govfakenotify@email.com'
                        },
                        "uri": "#{base_url}/v2/notifications/#{id}",
                        "template": {
                          "id": 'f33517ff-2a88-4f6e-b855-c550268ce08a',
                          "version": 1,
                          "uri": "#{base_url}/v2/template/ceb50d92-100d-4b8b-b559-14fa3b091cd"
                        }
                      })
    end

    private

    attr_reader :params, :store, :attachment_store, :base_url, :message_body, :id, :service

    def send_email_from_template(template_data) # rubocop:disable Metrics/MethodLength
      pre_process_files
      our_params = params
      our_html_body = mail_message_html(template_data)
      our_text_body = mail_message_text(template_data)
      our_service = service
      @message_body = our_html_body
      mail = Mail.new do
        from    our_service['service_email']
        to      our_params['email_address']
        subject template_data['subject']
        html_part do
          content_type 'text/html; charset=UTF-8'
          body our_html_body
        end
        text_part do
          body our_text_body
        end
      end
      mail.deliver
      @id = SecureRandom.uuid
    end

    def persist_status(template_data) # rubocop:disable Metrics/MethodLength
      store.transaction do
        store["message-#{id}"] = { id: id,
                                   email_address: params['email_address'],
                                   type: 'email',
                                   status: 'delivered',
                                   template: {
                                     Version: 1,
                                     id: 'f33517ff-2a88-4f6e-b855-c550268ce08a',
                                     uri: "#{base_url}/v2/template/ceb50d92-100d-4b8b-b559-14fa3b091cd"
                                   },
                                   body: message_body,
                                   subject: template_data['subject'],
                                   created_at: Time.now.to_s }
      end
    end

    def pre_process_files
      params['personalisation'].each_pair do |key, value|
        next unless value.is_a?(Hash) && value.keys.include?('file')

        params['personalisation'][key] = attachment_store.store(value)
      end
    end

    def mail_message_html(template_data)
      layout = Tilt.new(File.absolute_path('../../views/layouts/govuk.html.erb', __dir__))
      layout.render do
        template_content_html(template_data)
      end
    end

    def mail_message_text(template_data)
      layout = Tilt.new(File.absolute_path('../../views/layouts/govuk.text.erb', __dir__))
      layout.render do
        template_content_text(template_data)
      end
    end

    def template_content_html(template_data)
      template = template_data['message']
      buffer = ''.dup
      template.each_line do |line|
        buffer << format_line_html(line)
      end
      buffer
    end

    def template_content_text(template_data)
      template = template_data['message']
      buffer = ''.dup
      template.each_line do |line|
        buffer << format_line_text(line)
      end
      buffer
    end

    def format_line_html(line)
      replaced = line.gsub(/\(\(([^)]*)\)\)/) do
        post_process_value_html params['personalisation'][Regexp.last_match[1]]
      end
      wrap_line_html(replaced)
    end

    def format_line_text(line)
      replaced = line.gsub(/\(\(([^)]*)\)\)/) do
        post_process_value_text params['personalisation'][Regexp.last_match[1]]
      end
      wrap_line_text(replaced)
    end

    def post_process_value_html(value)
      return value unless value.is_a?(Hash) && value.keys.include?('file')

      render_file_html(value)
    end

    def post_process_value_text(value)
      return value unless value.is_a?(Hash) && value.keys.include?('file')

      render_file_text(value)
    end

    def wrap_line_html(line)
      case line
      when /^---/ then render_horizontal_line_html
      else render_paragraph_html(line)
      end
    end

    def wrap_line_text(line)
      case line
      when /^---/ then render_horizontal_line_text
      else render_paragraph_text(line)
      end
    end

    def render_horizontal_line_html
      Tilt.new(File.absolute_path('../../views/govuk/horizontal_line.html.erb', __dir__)).render
    end

    def render_horizontal_line_text
      Tilt.new(File.absolute_path('../../views/govuk/horizontal_line.text.erb', __dir__)).render
    end

    def render_paragraph_html(line)
      Tilt.new(File.absolute_path('../../views/govuk/paragraph.html.erb', __dir__)).render(nil, content: line)
    end

    def render_paragraph_text(line)
      Tilt.new(File.absolute_path('../../views/govuk/paragraph.text.erb', __dir__)).render(nil, content: line)
    end

    def render_file_html(file_data)
      Tilt.new(File.absolute_path('../../views/govuk/file.html.erb', __dir__)).render(nil, file_data: file_data,
                                                                                           base_url: base_url)
    end

    def render_file_text(file_data)
      Tilt.new(File.absolute_path('../../views/govuk/file.text.erb', __dir__)).render(nil, file_data: file_data,
                                                                                           base_url: base_url)
    end
  end
end
