module Web::Controllers::App
  class Logout
    include Web::Action
    include Hanami::Action::Session
    
    def call(params)
      if logged_in?
        params.env['warden'].logout
      end
      redirect_to routes.root_path
    end
  end
end
