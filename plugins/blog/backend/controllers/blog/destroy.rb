module Backend::Controllers::Blog
  class Destroy
    include Api::Action
    include ::Blog::BlogControllerMethods

    expose :post

    def call(params)
      @post  = blog.by_slug(params[:slug])
      @post.i18n(params[:lang])

      blog.destroy(@post, params[:lang])
      
    end
  end
end
