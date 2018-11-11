module Backend::Controllers::User
  class Index
    include Api::Action

    expose :user

    def call(params)
      @user = adapter(:user).user
    end
  end
end
