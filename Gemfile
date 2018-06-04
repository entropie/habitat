puts "Gemfile mother" if $DEBUG

source 'https://rubygems.org'

gem 'rake'
gem 'hanami',       '~> 1.1'
gem 'hanami-model', '~> 1.1'

gem "subcommand"
gem "sqlite3"


gem 'hanami-webpack', github: 'entropie/hanami-webpack'
gem "bootstrap", '~> 4.0.0'

gem 'haml'

gem 'sass'

gem 'warden'
gem 'bcrypt'
gem "sequel"
gem "redcarpet"

gem "nokogiri"

gem "unicorn"

gem "dimensions"

gem "flickraw"

gem "builder"

gem "capistrano", "~> 3.6", require: false
gem "capistrano-bundler", '~> 1.3'
gem "capistrano-rvm"

gem "multi_json"
gem "roar"
gem "uglifier"


group :development do
  gem 'shotgun'
end

group :test, :development, :production do
  gem 'dotenv', '~> 2.0'
end

group :test do
  gem 'minitest'
  gem 'capybara'
end

group :production do
  gem 'puma'
end
