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
        get     '/', to: "dashboard#index", as: :dashboard

        if_plugin(:user) do
          get   'login',             to: "user#login", as:  :login
          post  'login',            to: "user#login"
          get   'logout',            to: "user#logout", as: :logout
        end
        
        if_plugin(:blog) do
          namespace :blog do

            get  '/create',      to: "blog#edit", as:  :postCreate
            post '/create',     to: "blog#edit"

            get  '/:slug',       to: "blog#post", as:  :post

            get  '/:slug/edit',        to: "blog#edit", as:  :postEdit
            get  '/:slug/destroy',        to: "blog#destroy", as:  :postKill

            get  '/:slug/publish',  to: "blog#publish", as:  :postPublish

            post '/:slug/edit', to: "blog#edit"

            get  '/page/:page',  to: "blog#index", as: :posts
            get  '/',            to: "blog#index", as: :blog

          end
        end

        if_plugin(:snippets) do
          namespace :snippets do
            get  '/create',       to: "snippets#create",  as: :snippetsCreate
            get  '/:slug',        to: "snippets#snippet", as: :snippet
            get  '/:slug/edit',   to: "snippets#edit",    as: :snippetEdit
            post '/:slug/edit',   to: "snippets#edit"
            get  '/',             to: "snippets#index",   as: :snippets
          end
        end

        if_plugin(:user) do
          namespace :user do
            get  '/',             to: "user#index",   as: :user
          end
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

        if Habitat.quart.plugins.enabled?(:blog)
          include ::Blog::BlogControllerMethods
        end

      end

      view.prepare do

        if Habitat.quart.plugins.enabled?(:blog)
          include ::Blog::BlogViewMethods
        end
        

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

