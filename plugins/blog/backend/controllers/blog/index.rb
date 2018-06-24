module Backend::Controllers::Blog
  class Index
    include Api::Action
    include ::Blog::BlogControllerMethods
    expose :posts
    def call(params)
      @title = "Hi"
      @posts = blog.posts.sort_by {|p| p.created_at }.reverse
      @pager = Pager.paginate(params, @posts)
    end
  end
end
