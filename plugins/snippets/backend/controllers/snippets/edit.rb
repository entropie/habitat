module Backend::Controllers::Snippets
  class Edit
    include Backend::Action

    expose :snippet

    def snippets
      adapter(:snippets)
    end
    
    def call(params)
      @snippet = snippets.select(params[:slug])
      if request.post?
        snippets.store(snippet, params[:content])
        redirect_to routes.snippet_path(snippet.ident)
      end
    end
  end
end
