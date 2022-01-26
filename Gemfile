source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp

gem 'bootsnap', '>= 1.1.0', require: false
gem 'rails', '>= 6.1.4.4', '< 7.0.0'
gem 'puma', '~> 5.6'
gem 'redis', '~> 4.5'
gem 'sentry-rails', '~> 4.9.0'
gem 'sentry-ruby', '~> 4.9.2'
gem 'jwt'
gem 'sqlite3'

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
  gem 'shoulda-matchers', '~> 5.1'
  gem 'simplecov'
  gem 'simplecov-console', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
