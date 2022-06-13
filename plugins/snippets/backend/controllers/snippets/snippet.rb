module Backend::Controllers::Snippets
  class Snippet
    include Backend::Action

    expose :snippet

    def call(params)
      @snippet = adapter(:snippets).select(params[:slug])
    end
  end
end
