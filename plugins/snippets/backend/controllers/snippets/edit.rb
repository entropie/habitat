module Backend::Controllers::Snippets
  class Edit
    include Api::Action

    def call(params)
      @snippet = adapter(:snippets).render(params[:slug])
    end
  end
end
