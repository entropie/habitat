module Api::Controllers::Post
  class Post
    include Api::Action

    def call(params)
      # if @post
      #   hash = Api::Representers::FullPost.new(@post).to_hash
      # end

      hash = {}
      self.status = 200
      self.body = hash.to_json
    end
  end
end
