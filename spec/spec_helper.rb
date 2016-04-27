require_relative 'support/vcr'
require_relative 'support/omniauth_macro'
require_relative 'helpers'

require 'coveralls'
require 'webmock/rspec'

RSpec.configure do |config|
  config.include Helpers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.around(:each) do |example|
    options = example.metadata[:vcr] || {}
    if options[:record] == :skip
      VCR.turned_off(&example)
    else
      name = example.metadata[:full_description]
      VCR.use_cassette(name, options, &example)
    end
  end

  config.before :suite do
    FAVORITES_NUM = 5
  end
end
