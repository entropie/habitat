module Backend::Controllers::Snippets
  class Index
    include Api::Action

    expose :snippets, :pager
    def call(params)
      @snippets = adapter(:snippets).snippets.sort_by{|s| s.ident.to_s }
      @pager = Pager.paginate(params, @snippets, 10)
      @pager.link_proc = -> (n) { routes.snippetsPager_path(n) } 
    end
  end
end
