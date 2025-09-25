# frozen_string_literal: true

require 'rails/railtie'

module PostmailRuby
  # Railtie for integrating PostmailRuby with Rails. This railtie
  # registers custom delivery methods with Action Mailer and
  # configures Action Mailer based on PostmailRuby configuration. It
  # also offers an option to disable the default SMTP settings
  # configured by Rails, allowing PostmailRuby to be the sole mail
  # provider in a Rails application.
  class Railtie < ::Rails::Railtie
    initializer 'postmail_ruby.initialize' do
      ActiveSupport.on_load(:action_mailer) do
        # Register our delivery methods
        ActionMailer::Base.add_delivery_method :postmail_smtp, PostmailRuby::DeliveryMethod::SMTP
        ActionMailer::Base.add_delivery_method :postmail_api, PostmailRuby::DeliveryMethod::HTTP

        # Determine which delivery method to use based on configuration
        delivery_method = PostmailRuby.config.delivery_method
        ActionMailer::Base.delivery_method = case delivery_method
                                             when :api
                                               :postmail_api
                                             else
                                               :postmail_smtp
                                             end

        # If using SMTP, apply our SMTP settings and optionally
        # clear any default Rails SMTP settings. The
        # disable_default_smtp? flag removes Rails SMTP settings
        # before applying PostmailRuby settings.
        if delivery_method == :smtp
          if PostmailRuby.config.disable_default_smtp?
            # Clear any pre-existing SMTP settings so they do not
            # interfere with Postmail's configuration
            ActionMailer::Base.smtp_settings = {}
          end
          ActionMailer::Base.smtp_settings = PostmailRuby.config.smtp_settings
        end
      end
    end
  end
end
