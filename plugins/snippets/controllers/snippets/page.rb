module Web::Controllers::Snippets
  class Page
    include Web::Action
    include Snippets::SnippetsControllerMethods

    expose :snippet

    def call(params)
      slug = params[:slug]
      lparams = params.env["router.request"].path
      @snippet = snippet_page(slug, lparams, params)
      @page_title = t("pagetitle-#{snippet.ident}")
      
      halt 404 unless snippet
    end
  end
end
