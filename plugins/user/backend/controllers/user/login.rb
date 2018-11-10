module Backend::Controllers::User
  class Login
    include Api::Action
    include Hanami::Action::Session

    def call(params)
      
      if logged_in?
        redirect_to routes.dashboard_path
      end

      if request.post?
        if params.env['warden'].authenticate(:password)
          redirect_to routes.dashboard_path
          p 1
        else
          flash[:message] = 'Invalid credentials.'
          p 2
          redirect_to routes.login_path
        end
        exit
      end

    end
  end
end
