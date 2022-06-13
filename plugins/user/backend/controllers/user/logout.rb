module Backend::Controllers::User
  class Logout
    include Backend::Action
    include Hanami::Action::Session

    def call(params)
      if logged_in?
        params.env['warden'].logout
      end
      redirect_to "/"
    end
  end
end
