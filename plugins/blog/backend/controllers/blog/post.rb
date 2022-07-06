module Backend::Controllers::Blog
  class Post
    include Backend::Action
    include ::Blog::BlogControllerMethods
    expose :post
    def call(params)
      @post = blog.by_slug(params[:slug])
      @post.i18n(params[:lang])
    end
  end
end
