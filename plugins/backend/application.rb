# coding: utf-8
require 'hanami/helpers'
require 'hanami/assets'

module Backend

  class Application < Hanami::Application
    configure do
      root __dir__

      templates 'templates'
      layout :application

      cookies true

      routes do
        get     '/', to: "dashboard#index", as: :dashboard

        Habitat.plugin_enabled?(:user) do
          get   'login',             to: "user#login", as:     :login
          post  'login',             to: "user#login"
          get   'logout',            to: "user#logout", as:    :logout

          namespace :user do
            get   '/create',         to: "user#create",  as:     :usercreate
            post  '/create',         to: "user#create",  as:     :usercreate
            get   '/:name',          to: "user#user",    as:     :userpage
            post  '/edit/:user_id',  to: "user#edit",    as:     :useredit
            get   '/',               to: "user#index",   as:     :user
          end
        end

        Habitat.plugin_enabled?(:blog) do
          namespace :blog do

            get  '/create',          to: "blog#edit", as:      :postCreate
            post '/create',          to: "blog#edit"

            get '/templates',        to: "blog#templates", as: :templates

            get '/templates/create',       to: "blog#template_create",  as: :templateCreate
            post '/templates/create',      to: "blog#template_create",  as: :templateCreateOrEdit

            get '/templates/:slug',       to: "blog#template",         as: :template
            get '/templates/:slug/edit',  to: "blog#template",         as: :templateEdit
            get '/templates/:slug/delete',to: "blog#template_delete",  as: :templateDelete
            get '/templates/:slug/duplicate',to: "blog#template_duplicate",  as: :templateDuplicate

            get  '/:slug',           to: "blog#post", as:      :post

            get  '/:slug/edit',      to: "blog#edit", as:      :postEdit
            get  '/:slug/destroy',   to: "blog#destroy", as:   :postKill

            get  '/:slug/publish',   to: "blog#publish", as:   :postPublish

            post '/:slug/edit',      to: "blog#edit"

            get  '/page/:page',      to: "blog#index", as:     :posts
            get  '/',                to: "blog#index", as:     :blog


          end
        end

        Habitat.plugin_enabled?(:tumblog) do
          namespace :tumblog do
            get  '/edit/:slug',      to: "tumblog#create_or_edit", as:     :tumblogEdit
            get  '/publish/:slug',   to: "tumblog#publish",        as:     :tumblogPublish
            get  '/create',          to: "tumblog#create",         as:     :tumblogCreate
            get  '/create_or_edit/:slug',  to: "tumblog#create_or_edit", as:     :tumblogCreateOrEdit
            get  '/destroy/:slug',   to: "tumblog#destroy",        as:     :tumblogDestroy
            get  '/page/:page',      to: "tumblog#index",          as:     :tumblogs
            get  '/',                to: "tumblog#index",          as:     :tumblog

          end
        end

        Habitat.plugin_enabled?(:galleries) do
          namespace :galleries do

            get  '/create',          to: "galleries#create", as:   :galleriesCreate
            post '/create',          to: "galleries#create"
            get  '/show/:slug',      to: "galleries#show", as:   :gallery
            post '/edit/:slug',      to: "galleries#edit", as:   :galleryEdit

            post '/upload/:slug',    to: "galleries#upload", as: :galleryUpload
            post '/control/:slug/:hash', to: "galleries#control", as: :galleryCntrl

            get  '/remove/:slug/:hash', to: "galleries#remove", as: :galleryRemoveImage


            get  '/',                to: "galleries#index", as:    :galleries
            get  '/page/:page',      to: "galleries#index", as:    :galleriesPager
          end
        end

        Habitat.plugin_enabled?(:felle) do
          namespace :felle do
            get  '/',                to: "felle#index", as:    :felle
            get  '/page/:page',      to: "felle#index", as:    :fellePager
            get  '/create',          to: "felle#edit", as:     :felleCreate
            post '/create',          to: "felle#edit"

            get  '/:slug/edit',      to: "felle#edit", as:     :felleEdit
            post '/:slug/edit',      to: "felle#edit"
          end
        end

        Habitat.plugin_enabled?(:snippets) do
          namespace :snippets do
            get  '/create',       to: "snippets#create",  as:   :snippetsCreate
            post '/create',       to: "snippets#create"
            get  '/:slug',        to: "snippets#snippet", as:  :snippet
            get  '/:slug/edit',   to: "snippets#edit",    as:  :snippetEdit
            post '/:slug/edit',   to: "snippets#edit"
            get  '/',             to: "snippets#index",   as:  :snippets
            get  '/page/:page',   to: "snippets#index",   as:  :snippetsPager
          end
        end

        Habitat.plugin_enabled?(:t) do
          namespace :t do
            get  '/create',         to: "t#create",         as:   :tCreate

            post '/create_or_edit/:slug', to: "t#create_or_edit", as:   :tCreateEdit
            post '/create_or_edit', to: "t#create_or_edit", as:   :tCreateEdit
            get  '/:slug/edit',     to: "t#edit",           as:   :tEdit
            get  '/',               to: "t#index",          as:   :t
          end

        end

        Habitat.plugin_enabled?(:stars) do
          namespace :stars do
            get  '/create',       to: "stars#create_or_edit", as:   :starsCreate
            post '/create',       to: "stars#create_or_edit"
            get  '/',             to: "stars#index",          as:   :stars
            get  '/page/:page',   to: "stars#index",          as:   :starsPager
            get  '/:ident/edit',  to: "stars#create_or_edit", as:   :starEdit
            post '/:ident/edit',  to: "stars#create_or_edit"
            get  '/:ident/remove',to: "stars#destroy",        as:   :starDestroy
          end
        end



        Habitat.plugin_enabled?(:booking) do
          namespace :booking do

            get  '/events/',             to: "booking#events", as:         :events
            get  '/events/create',       to: "booking#eventscreate", as:   :eventCreate
            get  '/events/:page',        to: "booking#events", as:         :eventsPager

            post '/events/create',       to: "booking#eventscreate"
            get  '/events/:slug/edit',   to: "booking#eventsedit", as:     :eventEdit
            post '/events/:slug/edit',   to: "booking#eventsedit"
            get  '/events/:slug/destroy',  to: "booking#eventdestroy", as:   :eventDestroy

            get  '/events/:slug',        to: "booking#event", as:          :event
            get  '/events/publishtoggle/:slug',to: "booking#eventtogglepublish", as: :eventTPublish

            get  '/workdays/',           to: "booking#workdays", as:       :workdays

            get  '/',                   to: "booking#index", as:           :booking

            #get  '/page/:page',   to: "booking#index", as:    :bookingPager
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
      middleware.use Rack::Session::Cookie, secret: Habitat.quart.secret

      controller.prepare do
        if Habitat.quart.plugins.enabled?(:blog)
          include ::Blog::BlogControllerMethods
        end

        if Habitat.quart.plugins.enabled?(:booking)
          include ::Booking::BookingControllerMethods
        end

        before :reject_unless_authenticated
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

