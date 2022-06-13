module Backend::Controllers::User
  class Login
    include Backend::Action
    include Hanami::Action::Session

    def call(params)
      
      if logged_in?
        redirect_to routes.dashboard_path
      end

      if request.post?
        if params.env['warden'].authenticate(:password)
          redirect_to routes.dashboard_path
        else
          flash[:message] = 'Invalid credentials.'
          redirect_to routes.login_path
        end
        exit
      end

    end
  end
end
