module Api::Controllers::Post
  class Pid
    include Api::Action
    def call(params)
      hash = {}
      # if params[:pid]
      #   @post = find_by_pid(params[:pid])
      #   hash = Api::Representers::FullPost.new(@post).to_hash
      # end

      self.status = 200
      self.body =  hash.to_json
    end
  end
end
