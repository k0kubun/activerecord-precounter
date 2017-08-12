require 'bundler/setup'
require 'activerecord-precounter'
require 'active_record'

# Just picked from activerecord-precount, originated in ActiveRecord tests.
# TODO: This can be refactored.
require 'erb'
require 'yaml'
erb = ERB.new(File.read(File.expand_path('./config.yml', __dir__)))

TEST_ROOT       = File.expand_path(__dir__)
FIXTURES_ROOT   = TEST_ROOT + "/fixtures"
config = YAML.parse(erb.result(binding)).transform
config.fetch('connections').each do |adapter, connection|
  [
    ['arunit', 'activerecord_unittest'],
    ['arunit2', 'activerecord_unittest2'],
  ].each do |name, dbname|
    unless connection[name].is_a?(Hash)
      connection[name] = { 'database' => connection[name] }
    end

    connection[name]['database'] ||= dbname
    connection[name]['adapter']  ||= adapter
  end
end

connection_name = ENV.fetch('ARCONN', config.fetch('default_connection'))
connection_config = config.fetch('connections').fetch(connection_name)
puts "Using #{connection_name}"
ActiveRecord::Base.configurations = connection_config
ActiveRecord::Base.establish_connection :arunit

load_schema = proc do
  begin
    # silence verbose schema loading
    original_stdout = $stdout
    $stdout = StringIO.new

    adapter_name = ActiveRecord::Base.connection.adapter_name.downcase

    load File.expand_path('./schema.rb', __dir__)
  ensure
    $stdout = original_stdout
  end
end
load_schema.call

require 'models/favorite'
require 'models/tweet'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
