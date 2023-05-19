source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'rails', '~> 6.1.7'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'sidekiq'
gem 'aasm', '5.2.0'
gem 'paper_trail'
gem 'active_model_serializers'
gem 'kaminari'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails', '5.1.1'
  gem 'faker'
  gem 'rubocop', '1.23.0'
  gem 'rubocop-faker', '1.0.0'
  gem 'rubocop-performance', '1.12.0'
  gem 'rubocop-rails', '2.12.4'
  gem 'rubocop-rspec', '2.11.1'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
end

group :test do
  gem 'rspec-rails', '~> 6.0.0'
  gem 'shoulda-matchers', require: false
  gem 'rspec-sidekiq'
  gem 'database_cleaner-active_record'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
