module Backend::Controllers::Blog
  class Publish
    include Backend::Action
    include Blog::BlogControllerMethods

    def call(params)
      post = blog.by_slug(params[:slug])
      if post.draft?
        blog.to_post(post)

        if Habitat.quart.plugins.enabled?(:vgwort)
          post_with_vgw = post.with_plugin(VGWort)

          if post_with_vgw.id_attached?
          else
            attach_id = post_with_vgw.attach_id
          end
        end
      else
        blog.to_draft(post)
      end
      redirect_to routes.post_path(post.slug)      
    end
  end
end
