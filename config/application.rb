require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env)

module FlindersAPI2
  class Application < Rails::Application
    config.encoding = "utf-8"

    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    
    config.time_zone = 'Adelaide'
    config.active_record.default_timezone = :local

    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get]
      end
    end
  end
end
