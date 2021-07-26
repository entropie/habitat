module Blog

  class APIPost
    def initialize(hash)
      @posthash = hash
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
  end

  class ReadAPI

    attr_reader :endpoint, :posts

    include Habitat::Mixins::FU

    CACHE_EXPIRY = 60*60*24

    def initialize(endpoint)
      @endpoint = endpoint
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
        ReadAPI.cached = JSON.parse(response)["posts"].map{ |apip| APIPost.new(apip) }
      end
      ReadAPI.cached
    end
    
  end

end
