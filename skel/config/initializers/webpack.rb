require 'hanami/server'

p 1

Hanami::Server.prepend(Webpack::Watcher)
