require 'hanami/helpers'
require 'hanami/assets'

module Feed
  class Application < Hanami::Application
    configure do
      root __dir__
      routes do 
        get '/',            to: "feed#index", as: :posts
      end
      #default_request_format :json
      default_response_format :xml

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

    configure do
      controller.prepare do
        include ::Blog::BlogControllerMethods
        include ::Blog::BlogViewMethods

        def post_to_xml(builder, post)
          builder.item do
            builder.title post.title
            builder.author blog_author(post).name
            builder.link File.join(C[:host], "post", post.slug)
            builder.guid post.id
            builder.pubDate post.created_at.rfc2822
            # builder.description post.intro
            #builder.tag!("content:encoded", builder.cdata!(post.with_filter))
            builder.description "type" => "html" do
              builder.cdata!(post.with_filter)
            end
          end
        end

        def adapter(*arg)
          Habitat.adapter(*arg)
        end
      end
    end


  end
end

Habitat.mounts[ Feed::Application ] = "/feed"


