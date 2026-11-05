source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: '.ruby-version'

gem 'bootsnap', '>= 1.24.4', require: false
gem 'rails', '~> 8.1.3.1'
gem 'puma', '~> 7.2'
gem 'redis', '~> 5.0'
gem 'sentry-rails', '~> 5.21.0'
gem 'sentry-ruby', '~> 5.21.0'
gem 'jwt'

group :development, :test do
  gem 'dotenv', require: 'dotenv/load'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 7.0.2'
end

group :development do
  gem 'listen'
end

group :test do
  gem 'simplecov'
  gem 'simplecov-console', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
