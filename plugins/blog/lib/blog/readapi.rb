module Blog

  class ReadAPI

    attr_reader :endpoint, :posts

    def initialize(endpoint)
      @endpoint = endpoint
    end

    def posts
      unless @posts
        uri = URI(@endpoint)
        response = Net::HTTP.get(uri)
        @posts = JSON.parse(response)["posts"]
      end
      @posts
    end
    
  end

end
