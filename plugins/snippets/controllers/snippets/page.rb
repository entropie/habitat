module Web::Controllers::Snippets
  class Page
    include Web::Action
    include Snippets::SnippetsControllerMethods

    expose :snippet

    def call(params)
      slug = params[:slug]
      lparams = params.env["router.request"].path
      @snippet = snippet_page(slug, lparams, params)

      trans_string = "pagetitle-#{snippet.ident}"
      if T.included?(trans_string)
        @page_title = t(trans_string)
      end
      
      halt 404 unless snippet
    end
  end
end
