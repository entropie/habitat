module Backend::Controllers::Blog
  class Edit

    include Api::Action
    include ::Blog::BlogControllerMethods

    expose :post


    def call(params)
      @post  = blog.by_slug(params[:slug])

      @post.i18n(params[:lang]) if @post

      if request.post?

        params = params.to_h
        pimg = params.delete(:image)
        post = blog.update_or_create(params)

        post.i18n(params[:lang]) 

        if pimg
          blog.upload(post, pimg[:tempfile])
        end
        blog.store(post)
        redirect_to routes.post_path(post.slug)
      end
    end
  end
end
