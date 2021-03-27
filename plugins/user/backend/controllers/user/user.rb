module Backend::Controllers::User
  class User
    include Api::Action

    expose :user

    def call(params)
      @user = adapter(:user).user(params[:name])
      @user.password = nil
    end
  end
end
