
module Backend::Controllers::Blog
  class Index
    include Backend::Action
    include ::Blog::BlogControllerMethods
    expose :posts, :pager
    def call(params)
      @title = "Hi"
      @posts = blog.posts.sort_by {|p| p.created_at }.reverse
      @pager = Pager::BackendPager.new(params, @posts, 14)
      @pager.link_proc = -> (n) { routes.posts_path(n) }
    end
  end
end
