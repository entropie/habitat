require 'bundler/setup'
require 'hanami/setup'
require 'hanami/model'
require_relative '../lib/test'

require_relative '../../../lib/habitat'

Dir["#{ __dir__ }/initializers/*.rb"].each { |file| require_relative file }

q = Habitat.quart = Habitat::Quarters[:test]

require_relative '../apps/web/application'

# loads application files for active plugins
Habitat.load_application_files_for_plugins!

class Web::Application
  configure do
    instance_eval(&Habitat.default_application_config)
  end
end


Hanami.configure do
  Habitat.mounts.each_pair {|clz,mp|
    mount clz, at: mp
  }
  mount Web::Application, at: '/'

  model do
   ##
    # Database adapter
    #
    # Available options:
    #
    #  * SQL adapter
    #    adapter :sql, 'sqlite://db/foobar_development.sqlite3'
    #    adapter :sql, 'postgresql://localhost/foobar_development'
    #    adapter :sql, 'mysql://localhost/foobar_development'
    #
    adapter :sql, 'sqlite://db/foobar_development.sqlite3' #ENV['DATABASE_URL']

    ##
    # Migrations
    #
    migrations 'db/migrations'
    schema     'db/schema.sql'
  end

  mailer do
    # See http://hanamirb.org/guides/mailers/delivery
    delivery :test
  end

  environment :development do
    # See: http://hanamirb.org/guides/projects/logging
    logger level: :debug
  end

  environment :production do
    logger level: :info, formatter: :json, filter: []

    mailer do
      delivery :smtp, address: ENV['SMTP_HOST'], port: ENV['SMTP_PORT']
    end
  end
end


Habitat.quart.load_enviroment!
