$: << File.expand_path("../../lib", __FILE__)

require 'database_cleaner'
require 'mongoid'
require 'mongoid-rspec'
require 'mongoid/enum'

ENV['MONGOID_ENV'] = "test"

RSpec.configure do |config|
  config.include Mongoid::Matchers
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.after(:each) do
    Mongoid.purge!
  end
end

Mongo::Logger.logger.level = Logger::INFO if Mongoid::VERSION >= '5'

Mongoid.load!(File.expand_path("../support/mongoid.yml", __FILE__), :test)
