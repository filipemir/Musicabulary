Rails.application.config.assets.version = '1.0'
Rails.application.config.assets.precompile += %w( favorites.js sessions.js banner.js)

files = File.join(Rails.root, "lib", "*.rb")
Dir[files].each { |file| require file }