source 'https://rubygems.org'
ruby '2.0.0'

gem 'rails', '4.2.0'

gem 'pg'

gem 'mechanize'

gem 'puma'

gem 'feedjira'
gem 'responders', '~> 2.0'

gem 'rack-cors', :require => 'rack/cors'

gem 'numbers_in_words'

gem 'sanitize'

# cron jobs, works out of the box with with Capistrano
gem 'whenever'

group :assets do
    gem 'sass'
    gem 'sass-rails'
    gem 'coffee-rails'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'rspec_api_test'
  gem 'factory_girl'
  gem "factory_girl_rails", "~> 4.0"
end

group :development do
  gem 'capistrano', '~> 3.1'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
end

group :production do
  gem 'rails_12factor'
end
