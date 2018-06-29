module Tumblog

  module Api

    ENDPOINT = "http://#{ENV["HANAMI_HOST"]}:#{ENV["HANAMI_PORT"]||80}"

    def self.endpoint
      File.join(ENDPOINT, "api/post/new")
    end
    
    def self.submit(what, args: {})
      request = Request.new(endpoint: endpoint, what: what, args: args, token: Tumblog.token)
      request.submit
    end

    class Request
      attr_accessor :endpoint, :what, :token, :args
      
      def initialize(endpoint:, what:, token:, args: {})
        @endpoint = URI.parse(endpoint)
        @what = what
        @token = token
        @args = args
      end

      def options
        {
          :token => @token,
          :s => what,
        }
      end

      def submit
        http = Net::HTTP.new(endpoint.host, endpoint.port)
        http.request_post(endpoint.path)
        Net::HTTP.post_form(endpoint, options.merge(:read_timeout => 500))
      end
    end
  end
end
