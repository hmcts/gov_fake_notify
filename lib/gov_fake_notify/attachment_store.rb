# frozen_string_literal: true

require 'singleton'
require 'pstore'
require 'securerandom'
module GovFakeNotify
  # A central store for storing all state in the app - uses a basic PStore
  class AttachmentStore
    include Singleton

    #
    # Given a hash containing the data that comes from the client side 'prepare_upload' method,
    #  this method stores the data in a file and returns the same hash but with the base64 data
    #  replaced with a file path where the data is stored.
    #
    # @param [Hash] file_data The data as prepared by 'prepare_upload'
    # @option file_data [String] :file The base64 encoded file
    # @option file_data [Boolean] :is_csv Indicates if the file is csv or not
    #
    # @return [Hash] A copy of the file_data param but with the contents of file replaced
    #  with the path of where the file is stored.
    def store(file_data)
      file_path = File.join(attachments_path, SecureRandom.uuid)
      File.open(file_path, 'wb') do |file|
        file.write(Base64.decode64(file_data['file']))
      end
      file_data.merge('file' => file_path)
    end

    #
    # Fetch a file from the store
    #
    # @param [String] id The id of the file - which happens to be the filename
    # @return [Hash, Nil] A hash containing 'file' (the file path) OR nil if not found
    def fetch(id)
      file_path = File.join(attachments_path, id.gsub(/[^a-zA-Z0-9\-]/, ''))
      File.exist?(file_path) ? { 'file' => file_path } : nil
    end

    private

    attr_reader :attachments_path

    def initialize(attachments_path: GovFakeNotify.config.attachments_path)
      @attachments_path = attachments_path
    end
  end
end
