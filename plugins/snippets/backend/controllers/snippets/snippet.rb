module Backend::Controllers::Snippets
  class Snippet
    include Api::Action

    expose :snippet

    def call(params)
      @snippet = adapter(:snippets).render(params[:slug])
    end
  end
end