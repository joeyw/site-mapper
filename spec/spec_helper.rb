require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'rspec'
require 'site_mapper'
require 'webmock/rspec'

# Get fixture file contents
def fixture filepath
  File.read "spec/fixtures/#{filepath}"
end
