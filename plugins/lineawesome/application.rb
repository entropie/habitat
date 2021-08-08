require 'hanami/helpers'
require 'hanami/assets'

module LineAwesome
  class Application < Hanami::Application
    configure do
      root __dir__
      routes do 
        get '/*', to: Rack::Directory.new(File.join(__dir__, "assets"))
      end
      default_request_format :json
      #default_response_format :xml

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


    end

    configure :development do
      handle_exceptions false
      
    end
    configure :test do
      handle_exceptions false
    end


  end
end

Habitat.mounts[ LineAwesome::Application ] = "/a/lineawesome"


