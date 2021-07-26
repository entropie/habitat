module Api::Controllers::Post
  class Index
    include Api::Action

    def posts
      Habitat.adapter(:blog).posts
    end

    def call(params)
      limit = params[:limit] || 10
      self.status = 200
      ret_posts = posts.sort_by{ |p| p.created_at }.reverse.first(limit).map{ |p| p.to_hash }
      self.body = { posts: ret_posts }.to_json
    end
  end
end
