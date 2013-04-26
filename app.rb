# small rails-app for spinning up tests and serving examples

require 'action_controller/railtie'
require 'action_dispatch/railtie'
require 'jasminerice'
require 'guard/jasmine'
require 'sprockets/railtie'
require 'jquery-rails'
require 'underscore-rails'

class Application < Rails::Application
  config.cache_classes = true
  config.active_support.deprecation = :log
  config.assets.enabled = true
  config.assets.version = '1.0'
  config.assets.paths << File.expand_path('coffeescript', Rails.root)
  config.assets.paths << File.expand_path('css', Rails.root)
  config.secret_token = '9696be98e32a5f213730cb7ed6161c79'

  # insert own ActionDispatch::Static
  config.serve_static_assets = false
  config.middleware.insert_before ::Rack::Lock, ::ActionDispatch::Static, File.expand_path("../example", __FILE__)
end

Application.initialize!