# frozen_string_literal: true

require 'uri'

module PostmailRuby
  # Configuration holds all settings loaded from environment variables or via configuration block.
  # It provides helpers to build SMTP settings and determine if default Rails SMTP
  # configuration should be disabled.
  class Configuration
    # Delivery method to use (:smtp or :api)
    attr_accessor :delivery_method
    # API endpoint for HTTP delivery
    attr_accessor :api_endpoint
    # API key for HTTP delivery (used in X-Server-API-Key header)
    attr_accessor :api_key
    # SMTP host
    attr_accessor :smtp_host
    # SMTP port (integer)
    attr_accessor :smtp_port
    # SMTP username
    attr_accessor :smtp_username
    # SMTP password
    attr_accessor :smtp_password
    # SMTP authentication type (:plain, :login, etc.)
    attr_accessor :smtp_authentication
    # Enable STARTTLS for SMTP (boolean)
    attr_accessor :smtp_enable_starttls_auto
    # Use SSL/TLS implicit connection for SMTP (boolean)
    attr_accessor :smtp_ssl
    # Domain used for SMTP
    attr_accessor :smtp_domain

    def initialize
      # set defaults from environment variables
      @delivery_method = (ENV['POSTMAIL_DELIVERY_METHOD'] || 'smtp').downcase.to_sym
      @disable_default_smtp = truthy?(ENV['POSTMAIL_DISABLE_RAILS_SMTP'])

      @api_endpoint = ENV['POSTMAIL_API_ENDPOINT'] || 'https://postal.exanora.com/api/v1/send/message'
      @api_key      = ENV['POSTMAIL_API_KEY']

      @smtp_host    = ENV['POSTMAIL_SMTP_HOST'] || 'localhost'
      @smtp_port    = integer_or_nil(ENV['POSTMAIL_SMTP_PORT']) || 25
      @smtp_username = ENV['POSTMAIL_SMTP_USERNAME']
      @smtp_password = ENV['POSTMAIL_SMTP_PASSWORD']
      @smtp_authentication = (ENV['POSTMAIL_SMTP_AUTH'] || 'login').downcase.to_sym
      @smtp_enable_starttls_auto = truthy?(ENV['POSTMAIL_SMTP_ENABLE_STARTTLS_AUTO'])
      # If not explicitly set, enable_starttls_auto defaults to true unless SSL is enabled
      @smtp_enable_starttls_auto = !truthy?(ENV['POSTMAIL_SMTP_SSL']) if @smtp_enable_starttls_auto.nil?
      @smtp_ssl    = truthy?(ENV['POSTMAIL_SMTP_SSL'])
      @smtp_domain = ENV['POSTMAIL_SMTP_DOMAIN']
    end

    # Returns true if the default Rails SMTP configuration should be disabled.
    # When this is true, Postmail will clear `config.action_mailer.smtp_settings`.
    def disable_default_smtp?
      @disable_default_smtp
    end

    # Compose SMTP settings hash suitable for Mail::SMTP or ActionMailer.
    def smtp_settings
      settings = {
        address: smtp_host, port: smtp_port,
        user_name: smtp_username, password: smtp_password,
        authentication: smtp_authentication,
        enable_starttls_auto: smtp_enable_starttls_auto, ssl: smtp_ssl
      }
      settings[:domain] = smtp_domain if smtp_domain
      # Remove nil values to avoid overriding defaults
      settings.compact
    end

    private

    # Convert string to boolean if present, returns nil if value not provided.
    def truthy?(value)
      return nil if value.nil? || value.empty?

      case value.downcase
      when 'true', '1', 'yes', 'y'
        true
      when 'false', '0', 'no', 'n'
        false
      end
    end

    # Convert string to integer, returns nil if value is blank or not numeric.
    def integer_or_nil(value)
      return nil if value.nil? || value.to_s.strip.empty?

      begin
        Integer(value)
      rescue StandardError
        nil
      end
    end
  end
end
