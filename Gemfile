source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp

gem 'bootsnap', '>= 1.1.0', require: false
gem 'rails', '~> 7.0.4'
gem 'puma', '~> 6.0'
gem 'redis', '~> 5.0'
gem 'sentry-rails', '~> 5.8.0'
gem 'sentry-ruby', '~> 5.8.0'
gem 'jwt'
gem 'sqlite3'
# Adding this removes some deprecation warnings, caused by double-loading of the net-protocol library
# we *might* be able to remove this after upgrading to Ruby 3
gem 'net-http'

group :development, :test do
  gem 'dotenv-rails', require: 'dotenv/rails-now'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '>= 3.5.0'
end

group :development do
  gem 'listen'
  gem 'guard-rspec', require: false
end

group :test do
  gem 'factory_bot_rails', '~> 6.2'
  gem 'shoulda-matchers', '~> 5.3'
  gem 'simplecov'
  gem 'simplecov-console', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
