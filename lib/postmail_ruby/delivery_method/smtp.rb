# frozen_string_literal: true

require 'mail'

module PostmailRuby
  module DeliveryMethod
    # Provides a custom SMTP delivery method that reads its
    # configuration from PostmailRuby::Configuration. This class is
    # essentially a thin wrapper around Mail::SMTP, passing in
    # settings derived from environment variables. It allows
    # Action Mailer to use PostmailRuby configuration seamlessly.
    class SMTP
      attr_reader :settings

      # Initialize the SMTP delivery method. Accepts an options
      # hash which can override the configuration. Options are
      # merged with configuration on each delivery.
      #
      # @param [Hash] options options overriding configuration
      def initialize(options = {})
        @settings = options
      end

      # Delivers a Mail::Message via SMTP. Merges any options
      # provided during initialization with the configuration's
      # smtp_settings. Uses Mail::SMTP#deliver! to send the
      # message.
      #
      # @param [Mail::Message] mail the message to send
      def deliver!(mail)
        config_settings = PostmailRuby.config.smtp_settings
        smtp_settings = config_settings.merge(settings)
        smtp = ::Mail::SMTP.new(smtp_settings)
        smtp.deliver!(mail)
      end
    end
  end
end
