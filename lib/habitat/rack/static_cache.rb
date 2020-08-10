module Rack

  class StaticCache

    def initialize(app, options={})
      @app = app
      @urls = options[:urls]
      @no_cache = {}
      @urls.collect! do |url|
        if url  =~ /\*$/
          url_prefix = url.sub(/\*$/, '')
          @no_cache[url_prefix] = 1
          url_prefix
        else
          url
        end
      end
      root = options[:root] || Dir.pwd
      @file_server = Rack::File.new(root)
      @cache_duration = options[:duration] || 1
      @versioning_enabled = options.fetch(:versioning, true)
      if @versioning_enabled
        @version_regex = options.fetch(:version_regex, /-[\d.]+([.][a-zA-Z][\w]+)?$/)
      end
      @duration_in_seconds = self.duration_in_seconds
    end

    def call(env)
      path = env["PATH_INFO"]
      url = @urls.detect{ |u| path.index(u) == 0 }
      if url.nil?
        @app.call(env)
      else
        if @versioning_enabled
          path.sub!(@version_regex, '\1')
        end

        status, headers, body = @file_server.call(env)
        headers = Utils::HeaderHash.new(headers)

        if @no_cache[url].nil?
          headers['Cache-Control'] ="max-age=#{@duration_in_seconds}, public"
          headers['Expires'] = duration_in_words
        end
        headers['Date'] = Time.now.httpdate
        [status, headers, body]
      end
    end

    def duration_in_words
      (Time.now.utc + self.duration_in_seconds).httpdate
    end

    def duration_in_seconds
      (60 * 60 * 24 * 365 * @cache_duration).to_i
    end
  end
end
