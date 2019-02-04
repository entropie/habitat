module Backend::Controllers::Galleries
  class Index
    include Api::Action
    include Galleries::ControllerMethods

    expose :all, :pager

    def call(params)
      @all = galleries.all
      @pager = Pager.paginate(params, @all)
      @pager.link_proc = -> (n) { routes.galleriesPager_path(n) }

    end
  end
end
