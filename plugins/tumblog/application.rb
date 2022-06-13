require 'hanami/helpers'
require 'hanami/assets'

module Tumblog
  class Application < Hanami::Application
    configure do
      root __dir__
      routes do 
        namespace :api do

          # get '/new',             to: "tumblog#create"
          # post '/new',            to: "tumblog#create", as: :create

          # post '/:id/toggle',     to: "tumblog#toggle", as: :toggle
          # post '/:id/destroy',    to: "tumblog#destroy", as: :destroy
          # post '/:id/topic',      to: "tumblog#topic", as:  :topic

          # get '/',            to: "tumblog#index", as: :posts
          # get '/:slug',       to: "tumblog#index", as:  :post
          # get '/pid/:pid',    to: "tumblog#index", as:   :pid
        end
        
      end
      default_request_format :json
      default_response_format :json

      security.x_frame_options 'DENY'
      security.x_content_type_options 'nosniff'
      security.x_xss_protection '1; mode=block'
      security.content_security_policy %{
        form-action 'self';
        frame-ancestors 'self';
        base-uri 'self';
        default-src 'none';
        script-src 'self';
        connect-src 'self';
        img-src 'self' https: data:;
        style-src 'self' 'unsafe-inline' https:;
        font-src 'self';
        object-src 'none';
        plugin-types application/pdf;
        child-src 'self';
        frame-src 'self';
        media-src 'self'
      }

      # middleware.use Warden::Manager do |manager|
      #   manager.intercept_401 = false
      # end

      controller.prepare do
        include Tumblog::ControllerMethods
        before :check_token
      end


      # view.prepare do
      #   include Habitat
      #   include Habitat::WebAppMethods
      # end
      instance_eval(&Habitat.default_application_config)
    end

    configure :development do
      handle_exceptions false
      
    end
    configure :test do
      handle_exceptions false
    end


  end
end

Habitat.mounts[ Tumblog::Application ] = "/tumblog"


