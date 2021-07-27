root to: 'app#index'

get '/attachments/*',   to: Rack::Directory.new(Habitat.quart.media_path(:data))
get '/assets/*',        to: Rack::Directory.new(Habitat.quart.media_path(:assets))
