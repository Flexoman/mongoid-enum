$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'mongoid'
require 'mongoid-rspec'
require 'mongoid/enum'

ENV['MONGOID_ENV'] = 'test'

RSpec.configure do |config|
  config.include Mongoid::Matchers
  # config.before(:suite) do
  #   DatabaseCleaner.strategy = :truncation
  # end

  config.after(:each) do
    Mongoid.purge!
  end
end

I18n.load_path << 'spec/support/app.en.yml'
I18n.default_locale = :en

Mongo::Logger.logger.level = Logger::INFO if Mongoid::VERSION >= '5'

Mongoid.load!(File.expand_path('../support/mongoid.yml', __FILE__), :test)
