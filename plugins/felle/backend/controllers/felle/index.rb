module Backend::Controllers::Felle
  class Index
    include Api::Action
    include ::Felle::ControllerMethods

    expose :fell, :felle, :pager
    
    def call(params)
      @felle = felle.felle
      @pager = Pager.paginate(params, @felle, 16)
      @pager.link_proc = -> (n) {
        routes.fellePager_path(n)
      }
    end
  end
end
