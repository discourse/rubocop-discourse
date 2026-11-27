# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Discourse::NoTlsVerificationBypass, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it "registers an offense for VERIFY_NONE" do
    expect_offense(<<~RUBY)
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
                         ^^^^^^^^^^^^^^^^^^^^^^^^^ Discourse/NoTlsVerificationBypass: Do not disable TLS certificate or hostname verification.
      pop3.enable_ssl(::OpenSSL::SSL::VERIFY_NONE)
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Discourse/NoTlsVerificationBypass: Do not disable TLS certificate or hostname verification.
    RUBY
  end

  it "registers an offense for disabling options" do
    expect_offense(<<~RUBY)
      Excon.get(url, ssl_verify_peer: false)
                     ^^^^^^^^^^^^^^^^^^^^^^ Discourse/NoTlsVerificationBypass: Do not disable TLS certificate or hostname verification.
      Faraday.new(url, ssl: { verify: false })
                              ^^^^^^^^^^^^^ Discourse/NoTlsVerificationBypass: Do not disable TLS certificate or hostname verification.
    RUBY
  end

  it "registers an offense for disabling assignments" do
    expect_offense(<<~RUBY)
      http.verify_hostname = false
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Discourse/NoTlsVerificationBypass: Do not disable TLS certificate or hostname verification.
      ssl_options[:verify] = false
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Discourse/NoTlsVerificationBypass: Do not disable TLS certificate or hostname verification.
    RUBY
  end

  it "does not register an offense when verification stays on" do
    expect_no_offenses(<<~RUBY)
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.verify_hostname = true
      Excon.get(url, ssl_verify_peer: true)
      Faraday.new(url, ssl: { verify: true })
      ssl_options[:verify] = webhook.verify_certificate
      raise ArgumentError if mode == OpenSSL::SSL::VERIFY_NONE
      verified = context.verify_mode != OpenSSL::SSL::VERIFY_NONE
    RUBY
  end
end
