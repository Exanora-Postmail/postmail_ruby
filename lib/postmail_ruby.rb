# frozen_string_literal: true

require_relative 'postmail_ruby/version'
require_relative 'postmail_ruby/configuration'

# Main entry point for the Postmail gem. This module exposes
# configuration and helper methods to integrate the gem into a
# Ruby on Rails application. When loaded in a Rails environment,
# a Railtie is required automatically to register custom delivery
# methods with Action Mailer.
module PostmailRuby
  class << self
    # Accessor for the configuration instance. When first called
    # a new Configuration object is created and memoized. This
    # object reads environment variables to determine how Postmail
    # should behave (API vs SMTP, credentials, endpoints, etc.).
    #
    # @return [Postmail::Configuration]
    attr_accessor :configuration

    # Yields the configuration instance to a block so that callers
    # can override defaults at runtime. If no block is given the
    # current configuration is returned. This is the primary API
    # used to change settings in an initializer.
    #
    # @example Override the API endpoint
    #   Postmail.configure do |config|
    #     config.api_endpoint = "https://my-postal.example/api/v1/send/message"
    #   end
    #
    # @yieldparam [Postmail::Configuration] configuration
    # @return [Postmail::Configuration]
    def configure
      self.configuration ||= Configuration.new
      return configuration unless block_given?

      yield(configuration)
      configuration
    end

    # Ensures that a configuration instance exists. If the
    # configuration has not been initialized then a new one is
    # created. This method should be used internally when a
    # configuration is required.
    #
    # @return [Postmail::Configuration]
    def config
      self.configuration ||= Configuration.new
    end
  end
end

# Require delivery method classes. These require statements are
# placed outside of the Postmail module definition so that they
# are loaded when the gem is required. They rely on Postmail
# configuration, so configuration must be loaded first.
require_relative 'postmail_ruby/delivery_method/http'
require_relative 'postmail_ruby/delivery_method/smtp'

# Load the Railtie only if Rails is defined. The Railtie is
# responsible for registering delivery methods and setting up
# Action Mailer configuration based on environment variables.
require_relative 'postmail_ruby/railtie' if defined?(Rails)
