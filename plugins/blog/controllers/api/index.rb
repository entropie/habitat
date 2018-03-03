module Api::Controllers::Post
  class Index
    include Api::Action
    include Blog::Controller
    
    expose :posts

    def call(params)
      hashes = @posts.map do |pst|
        Api::Representers::Post.new(pst).to_hash
      end

      self.status = 200
      self.body = { posts: hashes }.to_json
    end
  end
end
