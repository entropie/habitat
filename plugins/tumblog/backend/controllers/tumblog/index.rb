module Backend::Controllers::Tumblog
  class Index
    include Backend::Action

    include ::Tumblog::ControllerMethods

    expose :posts, :pager

    def call(params)

      @posts = tumblog.entries
      
      @pager = Pager::BackendPager.new(params, @posts, 14)
      @pager.link_proc = -> (n) { routes.tumblogs_path(n) }
    end
  end
end
