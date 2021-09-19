# frozen_string_literal: true

require 'mail'
require 'erb'
require 'tilt'
module GovFakeNotify
  # A service used when the sending of an email is requested
  class SendEmailCommand
    def self.call(params)
      # do nothing yet
      new(params).call
    end

    def initialize(params, store: Store.instance)
      @params = params
      @store = store
    end

    def call
      template_data = store.transaction { store["template-#{params['template_id']}"] }
      send_email_from_template(template_data)
      self
    end

    def success?
      true
    end

    def to_json(*_args) # rubocop:disable Metrics/MethodLength
      ::JSON.generate({
                        "id": '740e5834-3a29-46b4-9a6f-16142fde533a',
                        "reference": 'STRING',
                        "content": {
                          "body": 'MESSAGE TEXT',
                          "from_number": 'SENDER'
                        },
                        "uri": 'http://localhost:8080/v2/notifications/740e5834-3a29-46b4-9a6f-16142fde533a',
                        "template": {
                          "id": 'f33517ff-2a88-4f6e-b855-c550268ce08a',
                          "version": 1,
                          "uri": 'https://localhost:8080/v2/template/ceb50d92-100d-4b8b-b559-14fa3b091cd'
                        }
                      })
    end

    private

    attr_reader :params, :store

    def send_email_from_template(template_data) # rubocop:disable Metrics/MethodLength
      our_params = params
      our_body = mail_message(template_data)
      mail = Mail.new do
        from    'govfakenotify@email.com'
        to      our_params['email_address']
        subject template_data['subject']
        html_part do
          content_type 'text/html; charset=UTF-8'
          body our_body
        end
        text_part do
          body 'text part to go here'
        end
      end
      mail.deliver
    end

    def mail_message(template_data)
      layout = Tilt.new(File.absolute_path('../../views/layouts/govuk.html.erb', __dir__))
      layout.render do
        template_content(template_data)
      end
    end

    def template_content(template_data)
      template = Base64.decode64(template_data['message'])
      buffer = ''.dup
      template.each_line do |line|
        buffer << format_line(line)
      end
      buffer
    end

    def format_line(line)
      replaced = line.gsub(/\(\(([^)]*)\)\)/) do
        params['personalisation'][Regexp.last_match[1]]
      end
      wrap_line(replaced)
    end

    def wrap_line(line)
      case line
      when /^---/ then render_horizontal_line
      else render_paragraph(line)
      end
    end

    def render_horizontal_line
      Tilt.new(File.absolute_path('../../views/govuk/horizontal_line.html.erb', __dir__)).render
    end

    def render_paragraph(line)
      Tilt.new(File.absolute_path('../../views/govuk/paragraph.html.erb', __dir__)).render(nil, content: line)
    end
  end
end
