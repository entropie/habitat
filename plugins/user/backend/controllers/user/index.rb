module Backend::Controllers::User
  class Index
    include Api::Action

    expose :user, :pager

    def call(params)
      @user = adapter(:user).user
      @pager = Pager.paginate(params, @user, 14)
      @pager.link_proc = -> (n) { routes.posts_path(n) }
    end
  end
end
