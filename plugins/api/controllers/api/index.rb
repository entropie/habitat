module Api::Controllers::Post
  class Index
    include Api::Action

    def call(params)
      hashes = {:a => 1}
      # hashes = @posts[0..8].map do |pst|
      #   Api::Representers::Post.new(pst).to_hash
      # end


      self.status = 200
      self.body = { posts: hashes }.to_json
    end
  end
end
