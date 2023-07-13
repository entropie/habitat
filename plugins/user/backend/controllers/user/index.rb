module Backend::Controllers::User
  class Index
    include Backend::Action

    expose :user, :pager

    def call(params)
      @user = adapter(:user).user
      @pager = Pager::BackendPager.new(params, @user)
      @pager.link_proc = -> (n) { routes.userpage_path(n) }
    end
  end
end
