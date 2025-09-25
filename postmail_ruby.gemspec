# frozen_string_literal: true

require_relative 'lib/postmail_ruby/version'

Gem::Specification.new do |spec|
  spec.name          = 'postmail_ruby'
  spec.version       = PostmailRuby::VERSION
  spec.authors       = ['DAKIN Judicaël']
  spec.email         = ['d.j.bidossessi@gmail.com']

  spec.summary       = 'Delivery methods for sending mail via SMTP or HTTP using environment variables'
  spec.description   = 'Postmail is a simple gem that adds custom Action Mailer delivery methods allowing you to send email via either SMTP or an HTTP API. The delivery method and all settings are configurable via environment variables so it can be easily switched at runtime without code changes.'
  spec.homepage      = 'https://postmail.exanora.com'
  spec.license       = 'MIT'

  # Files
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    Dir['lib/**/*', 'README.md'].reject { |f| File.directory?(f) }
  end

  # Dependencies
  spec.add_runtime_dependency 'mail', '~> 2.7'
  # No explicit dependency on rails; the Railtie is loaded if Rails is present

  spec.require_paths = ['lib']
end
