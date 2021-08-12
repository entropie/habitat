module Backend::Controllers::Stars
  class Index
    include Api::Action

    expose :stars, :pager

    def call(params)
      @stars = adapter(:stars).stars.sort_by{|s| s.ident.to_s }
      @pager = Pager::BackendPager.new(params, @stars, 10)
      @pager.link_proc = -> (n) { routes.starsPager_path(n) } 
    end
  end

end
