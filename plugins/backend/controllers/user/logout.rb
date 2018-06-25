module Backend::Controllers::User
  class Logout
    include Api::Action
    include Hanami::Action::Session

    def call(params)
      if logged_in?
        params.env['warden'].logout
      end
      redirect_to routes.dashboard_path
    end
  end
end
