source "https://rubygems.org"

gem "annotaterb", "~> 4.25"
gem "anthropic", "~> 1.80"
gem "awesome_print", "~> 1.9"
gem "bootsnap", require: false
gem "cssbundling-rails"
gem "devise", "~> 5.0"
gem "dotenv-rails", "~> 3.2"
gem "feedjira", "~> 4.0"
gem "httparty", "~> 0.24.3"
gem "image_processing", "~> 1.2"
gem "io-console", "0.9.4"
gem "jbuilder"
gem "jsbundling-rails"
gem "kamal", require: false
gem "propshaft"
gem "puma", ">= 5.0"
gem "rails", "~> 8.1.4"
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"
gem "solid_queue_monitor", "~> 2.2"
gem "sqlite3", ">= 2.1"
gem "stimulus-rails"
gem "thruster", require: false
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development do
  gem "web-console"
end

group :development, :test do
  gem "brakeman", require: false
  gem "bundler-audit", require: false
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "rspec-rails", "~> 8.0"
  gem "rubocop-rails-omakase", require: false
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webmock", "~> 3.26"
end

group :development do
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rbenv'        # or capistrano-rvm depending on your ruby manager
  gem "capistrano3-puma", "~> 7.1"
  gem 'capistrano-nvm', require: false

  # capistrano
  gem "ed25519", "~> 1.4" 
  gem "bcrypt_pbkdf", "~> 1.1"
end
