module Web::Controllers::App
  class Login
    include Web::Action
    include Hanami::Action::Session

    def call(params)

      if logged_in?
        redirect_to routes.root_path
      end

      if request.post?
        if params.env['warden'].authenticate(:password)
          redirect_to routes.root_path
        else
          flash[:message] = 'Invalid credentials.'
          redirect_to routes.login_path
        end
      end
    end
  end
end
