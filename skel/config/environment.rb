require 'bundler/setup'
require 'hanami/setup'
require 'hanami/model'
require_relative '../lib/%%%identifier%%%'

require_relative '../apps/web/application'

require_relative '../../../lib/habitat'

Dir["#{ __dir__ }/initializers/*.rb"].each { |file| require_relative file }

Habitat.quart = Habitat::Quarters[:%%%identifier%%%]

Hanami.configure do
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
    root 'lib/%%%identifier%%%/mailers'

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



