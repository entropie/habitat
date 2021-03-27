module Backend::Controllers::User
  class Create
    include Api::Action

    expose :user
    def call(params)
      paramhash = params.to_hash

      @user = ::User::User.new.populate({})

      if request.post?
        pw2 = paramhash.delete(:password1)
        if paramhash[:password] == pw2
          @user = ::User::User.new.populate(paramhash)
          @user.populate(paramhash)
          adapter(:user).store(@user)

          redirect_to routes.userpage_path(@user.name)
        end
      end
    end
  end
end
