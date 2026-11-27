# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Discourse::NoNetHttpSettingsInStartBlock, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it "registers an offense for connection settings assigned in the block" do
    expect_offense(<<~RUBY)
      Net::HTTP.start(host, port, use_ssl: true) do |http|
        http.open_timeout = 5
        ^^^^^^^^^^^^^^^^^^^^^ Discourse/NoNetHttpSettingsInStartBlock: `open_timeout` set inside the `start` block only applies to reconnections. Pass it as an option to `start` instead.
        if secure
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Discourse/NoNetHttpSettingsInStartBlock: `verify_mode` set inside the `start` block only applies to reconnections. Pass it as an option to `start` instead.
        end
        http.get("/")
      end
    RUBY
  end

  it "registers an offense for subclasses and started instances" do
    expect_offense(<<~RUBY)
      FinalDestination::HTTP.start(host, port) { |http| http.ca_file = path }
                                                        ^^^^^^^^^^^^^^^^^^^ Discourse/NoNetHttpSettingsInStartBlock: `ca_file` set inside the `start` block only applies to reconnections. Pass it as an option to `start` instead.
      Net::HTTP.new(host, port).start do |connection|
        connection.use_ssl = true
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Discourse/NoNetHttpSettingsInStartBlock: `use_ssl` set inside the `start` block only applies to reconnections. Pass it as an option to `start` instead.
      end
    RUBY
  end

  it "does not register an offense for settings that apply to the open connection" do
    expect_no_offenses(<<~RUBY)
      Net::HTTP.start(host, port, use_ssl: true, open_timeout: 5) do |http|
        http.read_timeout = 5
        http.write_timeout = 5
        http.max_retries = 0
        http.get("/")
      end
    RUBY
  end

  it "does not register an offense for settings assigned before starting" do
    expect_no_offenses(<<~RUBY)
      http = Net::HTTP.new(host, port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.start { |connection| connection.get("/") }
      Server.start(port) { |server| server.open_timeout = 5 }
    RUBY
  end
end
