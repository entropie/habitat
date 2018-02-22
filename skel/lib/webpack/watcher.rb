module Webpack
  module Watcher
    def start
      spawn('./node_modules/.bin/webpack --progress --colors --watch')
      super
    end
  end
end
