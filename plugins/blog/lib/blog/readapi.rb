module Blog

  class ReadAPI
    attr_reader :endpoint

    def initialize(endpoint)
      @endpoint = endpoint
    end
  end

end
