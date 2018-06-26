require 'hanami/helpers'
require 'hanami/assets'


def if_plugin(plug, &blk)
  if Habitat.quart.plugins.activated?(plug)
    blk.call
  end
end

module Backend
  class Application < Hanami::Application
    configure do
      root __dir__

      templates 'templates'
      layout :application

      routes do
        get '/', to: "dashboard#index", as: :dashboard

        if_plugin(:user) do
          get 'login',             to: "user#login", as:  :login
          post 'login',            to: "user#login"
          get 'logout',            to: "user#logout", as: :logout
        end
        
        if_plugin(:blog) do
          get '/blog/',            to: "blog#index", as: :blog

          get '/blog/create',      to: "blog#edit", as:  :postCreate
          post '/blog/create',     to: "blog#edit"

          get '/blog/:slug',       to: "blog#post", as:  :post


          get '/blog/:slug/edit',  to: "blog#edit", as:  :postEdit

          get '/blog/:slug/publish',  to: "blog#publish", as:  :postPublish

          post '/blog/:slug/edit', to: "blog#edit"

          get '/blog/page/:page',  to: "blog#index", as: :posts
        end

        if_plugin(:snippets) do
          get '/snippets/',             to: "snippets#index",   as: :snippets
          get '/snippets/:slug',        to: "snippets#snippet", as: :snippet
          get '/snippets/:slug/edit',   to: "snippets#edit",    as: :snippetEdit
          post '/snippets/:slug/edit',   to: "snippets#edit"
        end
      end

      security.x_frame_options 'DENY'
      security.x_content_type_options 'nosniff'
      security.x_xss_protection '1; mode=block'
      security.content_security_policy %{
        form-action 'self';
      }

      # middleware.use Warden::Manager do |manager|
      #   manager.intercept_401 = false
      # end

      # view.prepare do
      #   include Habitat
      #   include Habitat::WebAppMethods
      # end
      instance_eval(&Habitat.default_application_config)

      controller.prepare do
        def reject_unless_authenticated
          logging_in = ["login", "logout"].include?(params.env["REQUEST_PATH"].split("/").last)
          if not logged_in? and not logging_in
            redirect_to "/" 
            exit
          end
        end

        before :reject_unless_authenticated
        include ::Blog::BlogControllerMethods
      end

      view.prepare do

        include ::Blog::BlogViewMethods

        def Snip(arg)
          Habitat.adapter(:snippets).render(arg, locals[:params])
        end

        def routes
          Backend.routes
        end
      end
    end

    configure :development do
      handle_exceptions false
    end
    # configure :production do
    #   handle_exceptions false
    # end
    configure :test do
      handle_exceptions false
    end
  end
end

Habitat.mounts[ Backend::Application ] = "/backend"
