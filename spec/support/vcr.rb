require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.default_cassette_options = { record: :new_episodes }
end
