module Backend::Controllers::Blog
  class Post
    include Api::Action
    include ::Blog::BlogControllerMethods
    expose :post
    def call(params)
      @post  = blog.by_slug(params[:slug])
    end
  end
end
