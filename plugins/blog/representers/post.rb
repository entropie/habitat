require 'roar/decorator'
require 'roar/json'

module Api::Representers
  class Post < Roar::Decorator
    include Roar::JSON
    property :title
    property :author
    property :tags
    property :pid
    property :slug
    property :image
    property :date
  end

  class FullPost < Post

    module PostDecorator
      def content
        cnt = super
        html_file = Habitat.quart.media_path("blog/attachments/", slug, "enginecache_post.html")
        if File.exist?(html_file)
          a = File.open(html_file).read
          a
        else
          cnt
        end
      end
    end

    
    def initialize(arg)
      super(arg.extend(PostDecorator))
    end

    
    property :content
  end
end
