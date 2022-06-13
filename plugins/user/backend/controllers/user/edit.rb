module Backend::Controllers::User
  class Edit
    include Backend::Action

    expose :user
    
    def call(params)
      @user = adapter(:user).by_id(params[:user_id])
      @user.populate(params.to_hash)

      adapter(:user).store(@user)
      redirect_to routes.userpage_path(@user.name)
    end
  end
end
