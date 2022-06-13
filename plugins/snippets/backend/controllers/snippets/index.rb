module Backend::Controllers::Snippets
  class Index
    include Backend::Action

    expose :snippets, :pager
    def call(params)
      @snippets = adapter(:snippets).snippets.select{|s|
        if s.respond_to?(:parent?)
          s.parent?
        else
          true
        end
      }.sort_by{|s| s.ident.to_s }
      @pager = Pager::BackendPager.new(params, @snippets, 10)
      @pager.link_proc = -> (n) { routes.snippetsPager_path(n) } 
    end
  end
end
