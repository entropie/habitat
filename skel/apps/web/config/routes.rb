root to: 'app#index'

get '/login', to: "app#login", as: :login
get '/logout', to: "app#logout", as: :logout

get '/attachments/*',   to: Rack::Directory.new(Habitat.quart.media_path(:data))
get '/assets/*',        to: Rack::Directory.new(Habitat.quart.media_path(:assets))
