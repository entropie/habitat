module Backend::Controllers::Blog
  class Templates
    include Backend::Action
    include Blog:: BlogControllerMethods

    expose :templates, :pager

    def call(params)
      @templates = Blog.templates.map{|_, tmpl| tmpl}
      @pager = Pager.paginate(params, @templates, 14)
      @pager.link_proc = -> (n) { routes.template_path(n) }
    end
  end
end
