module Backend::Views::Blog
  class Templates
    include Backend::View
    include Blog::BlogControllerMethods

    def posts_for_template(tmpl, &blk)
      psts = blog.by_template(tmpl.to_sym)
      psts.each(&blk) if block_given?
      psts
    end
  end
end
