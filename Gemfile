source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.3"

gem "acts-as-taggable-on"
gem "bootsnap", ">= 1.4.2", require: false
gem "brakeman"
gem "browser"
gem "bundler-audit"
gem "daemons"
gem "delayed_job_active_record"
gem "devise"
gem "feedjira"
gem "foreman"
gem "haml"
gem "httparty"
gem "jbuilder", "~> 2.7"
gem "kaminari"
gem "mina"
gem "opml-parser"
gem "puma", "~> 5.5.1"
gem "rails", "~> 6.0.4", ">= 6.0.4.1"
gem "rubocop"
gem "rubocop-discourse"
gem "RubySunrise"
gem "sass-rails", ">= 6"
gem "sqlite3", "~> 1.4"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "valid_url", github: "ralovets/valid_url"
gem "webpacker", "~> 4.0"

group :development, :test do
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails"
  gem "nokogiri"
end

group :development do
  gem "listen", "~> 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"
end
