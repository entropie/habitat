module Blog

  class APIPost

    attr_reader :api

    def initialize(hash, api)
      @posthash, @api = hash, api
    end

    def created_at
      Time.parse(@posthash["created_at"])
    end

    def css_class
      "extern"
    end

    def slug
      @posthash["slug"]
    end

    def title
      @posthash["title"]
    end

    def intro_html
      @posthash["intro"]
    end

    class APIPostIMG
      attr_reader :image, :api
      def initialize(img, api)
        @image, @api = img, api
      end

      def css_background_defintion
        "background-image: url(%s)" % api.url(@image)
      end
    end

    def image
      APIPostIMG.new(@posthash["image"], api)
    end

    def to_human
      created_at.to_human
    end

    def url(*add)
      api.url(*add)
    end

    def post_url
      url("/post/", slug)

    end


  end

  class ReadAPI

    attr_reader :endpoint, :posts

    include Habitat::Mixins::FU

    CACHE_EXPIRY = 60*60*24

    def initialize(endpoint)
      @endpoint = endpoint
    end

    def url(*add)
      "https://%s" % File.join( URI.parse(endpoint).host, *add )
    end

    def self.cache_file
      Habitat.quart.media_path("api.yaml")
    end

    extend Habitat::Mixins::FU

    def self.cached
      ctime = ::File.ctime(cache_file) rescue nil
      if ctime and (r=Time.now - ctime) > CACHE_EXPIRY
        Habitat.log :info, "readapi: cache expired(#{ r }) clearing"
        rm_rf(cache_file)
        @cached = nil
        return @cached
      end
      @cached = YAML.load_file(cache_file) rescue nil
    end

    def self.cached=(obj)
      cache_file = Habitat.quart.media_path("api.yaml")
      write(cache_file, obj.to_yaml)
    end

    def posts
      unless ReadAPI.cached
        uri = URI(@endpoint)
        Habitat.log :info, "readapi: reading #{uri}"
        response = Net::HTTP.get(uri)
        Habitat.log :info, "readapi: result: #{ response.size }kb"
        ReadAPI.cached = JSON.parse(response)["posts"].map{ |apip| APIPost.new(apip, self) }
      end
      ReadAPI.cached
    end
    
  end

end
