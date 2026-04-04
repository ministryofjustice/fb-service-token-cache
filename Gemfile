source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp

gem 'bootsnap', '>= 1.1.0', require: false
gem 'rails', '~> 7.1.6.0'
gem 'puma', '~> 6.4'
gem 'redis', '~> 5.0'
gem 'sentry-rails', '~> 5.20', '>= 5.20.0'
gem 'sentry-ruby', '~> 5.14'
gem 'jwt'

group :development, :test do
  gem 'dotenv', require: 'dotenv/load'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '>= 7.0.2'
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
