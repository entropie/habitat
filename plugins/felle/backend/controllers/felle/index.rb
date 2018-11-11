module Backend::Controllers::Felle
  class Index
    include Api::Action
    include ::Felle::ControllerMethods

    expose :fell, :felle, :pager
    
    def call(params)
      @felle = felle.felle
      @pager = Pager.paginate(params, @felle, 14)
      @pager.link_proc = -> (n) { routes.felle_path(n) }
    end
  end
end
