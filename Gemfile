source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'bootsnap', '>= 1.1.0', require: false

gem 'dotenv-rails', require: 'dotenv/rails-now', group: [:development, :test]

gem 'jwt'

gem 'rails', '~> 5.2.2.1'
gem 'sqlite3'
gem 'puma', '~> 3.11'
gem 'redis', '~> 4.0'
gem 'sentry-raven'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'rspec-rails', '>= 3.5.0'
end

group :development do
  gem 'listen'
  gem 'guard-rspec', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails', '~> 4.0'
  gem 'faker'
  gem 'poltergeist'
  gem 'phantomjs'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 4.1'
  gem 'simplecov'
  gem 'simplecov-console', require: false
  gem 'webmock'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
