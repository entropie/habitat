module Backend::Controllers::User
  class Index
    include Backend::Action

    expose :user, :pager

    def call(params)
      @user = adapter(:user).user
      @pager = Pager::BackendPager.new(params, @user, 14)
      @pager.link_proc = -> (n) { routes.posts_path(n) }
    end
  end
end
