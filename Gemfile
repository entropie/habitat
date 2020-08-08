puts "Gemfile mother" if $DEBUG

source 'https://rubygems.org'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

gem 'rake'
gem 'hanami',       '1.3.2'
gem 'hanami-model', '1.3.2'

gem "subcommand"
gem "sqlite3"

gem "memcached"
gem 'hanami-webpack', github: 'entropie/hanami-webpack'
gem "bootstrap", '~> 4.0.0'

gem 'haml'

gem 'sassc'

gem 'jwt'
gem 'warden'
gem 'bcrypt'
gem "sequel"
gem "redcarpet"

gem "rake-compiler"

gem "nokogiri"

gem "unicorn"

gem "dimensions"

gem "flickraw", github: 'hanklords/flickraw'
gem "builder"

gem "capistrano", "= 3.11.0", require: false
gem "capistrano-bundler" #, '~> 1.3'
gem "capistrano-rvm"

gem "multi_json"
gem "roar"
gem "uglifier"

gem "webp-ffi"


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
