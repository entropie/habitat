module Api::Controllers::Post
  class Post
    include Api::Action
    include Blog::Controller
    
    expose :post

    def call(params)
      if @post
        hash = Api::Representers::FullPost.new(@post).to_hash
      end

      self.status = 200
      self.body = hash.to_json
    end
  end
end
