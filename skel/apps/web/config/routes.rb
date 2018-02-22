root to: 'app#index'

get '/login', to: "app#login", as: :login
get '/logout', to: "app#logout", as: :logout

post '/login', to: "app#login"

