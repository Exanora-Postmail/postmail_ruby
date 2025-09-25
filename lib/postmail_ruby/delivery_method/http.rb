# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'base64'

module PostmailRuby
  module DeliveryMethod
    # Implements a delivery method for Action Mailer that sends
    # messages via the Postal HTTP API. Instead of speaking SMTP
    # directly, this class packages the email into a JSON payload
    # and posts it to the configured Postal endpoint. An API key
    # must be provided via configuration for authentication.
    class HTTP
      attr_reader :settings

      # Initialize the HTTP delivery method. Accepts a hash of
      # options that may override configuration defaults. Options
      # are stored but not used directly; configuration is read
      # from PostmailRuby.config for each delivery to ensure the most
      # current environment variables are respected.
      #
      # @param [Hash] options delivery options (currently unused)
      def initialize(options = {})
        @settings = options
      end

      # Deliver a Mail::Message via the Postal API. Builds a JSON
      # payload including recipients, subject, plain and HTML parts
      # and attachments. Sends the payload as a POST request with
      # the API key in the X-Server-API-Key header. Raises an
      # exception if the request returns a non-success response.
      #
      # @param [Mail::Message] mail the message to send
      def deliver!(mail)
        config = PostmailRuby.config
        uri = URI.parse(config.api_endpoint)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        http.read_timeout = 15
        http.open_timeout = 5

        request = Net::HTTP::Post.new(uri.request_uri, {
                                        'Content-Type' => 'application/json',
                                        'X-Server-API-Key' => config.api_key.to_s
                                      })
        request.body = build_payload(mail, config).to_json

        response = http.request(request)
        unless response.is_a?(Net::HTTPSuccess)
          raise "Postal API responded with status #{response.code}: #{response.body}"
        end

        response
      end

      private

      # Build a hash representing the JSON payload expected by
      # Postal's API. Extracts addresses, subject, plain and HTML
      # bodies and encodes attachments as base64. Null values are
      # omitted from the final hash for brevity.
      #
      # @param [Mail::Message] mail
      # @param [PostmailRuby::Configuration] config
      # @return [Hash]
      def build_payload(mail, _config)
        {
          from: extract_sender(mail),
          to: extract_addresses(mail.to),
          cc: extract_addresses(mail.cc),
          bcc: extract_addresses(mail.bcc),
          subject: mail.subject.to_s,
          plain_body: extract_part(mail, 'text/plain'),
          html_body: extract_part(mail, 'text/html'),
          attachments: build_attachments(mail)
        }.compact
      end

      # Extract the sender address. The Mail object may store
      # from address as an array; we use the first entry. Returns
      # nil if no sender is specified.
      def extract_sender(mail)
        Array(mail.from).first
      end

      # Convert an array of addresses to a comma-separated string.
      # Returns nil if the array is blank.
      def extract_addresses(value)
        return nil if value.nil? || value.empty?

        Array(value).join(',')
      end

      # Extract a specific MIME part "../../postmail_ruby/delivery_method""."from the message. For
      # multipart messages, the first matching part "../../postmail_ruby/delivery_method""."is returned.
      # For non-multipart, the body is returned if the MIME type
      # matches. Returns nil if no matching part "../../postmail_ruby/delivery_method""."exists.
      def extract_part(mail, mime_type)
        if mail.multipart?
          mail.parts.find { |p| p.mime_type&.start_with?(mime_type) }
          part "../../postmail_ruby/delivery_method#{'.'.decoded}"
        else
          mail.mime_type&.start_with?(mime_type) ? mail.body.decoded : nil
        end
      end

      # Build an array of attachment hashes. Each attachment
      # includes name, content_type and base64 encoded data. If
      # there are no attachments the method returns nil to omit
      # the key from the payload.
      def build_attachments(mail)
        return nil if mail.attachments.empty?

        mail.attachments.map do |att|
          {
            name: att.filename.to_s,
            content_type: att.mime_type.to_s,
            data: Base64.strict_encode64(att.body.decoded)
          }
        end
      end
    end
  end
end
