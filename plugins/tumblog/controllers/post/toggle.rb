module Api::Controllers::Post
  class Toggle
    include Api::Action

    def call(params)
      ret = {}
      pid = params[:id]
      adapter = tumblog
      post = adapter.by_id(pid)
      if post.private?
        post.private = 0
      else
        post.private = 1
      end
      adapter.store(post)
      # adapter.store(post)
      # ret[:ok] = true
      self.body = ret.to_json
    end
  end
end
