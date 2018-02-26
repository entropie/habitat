puts "Gemfile mother" if $DEBUG



gem 'rake'
gem 'hanami',       '~> 1.1'
gem 'hanami-model', '~> 1.1'

gem "subcommand"
gem "sqlite3"


gem 'hanami-webpack', github: 'entropie/hanami-webpack'

gem 'haml'

gem 'sass'

gem 'warden'
gem 'bcrypt'
gem "sequel"

group :development do
  # Code reloading
  # See: http://hanamirb.org/guides/projects/code-reloading
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
