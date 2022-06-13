module Tumblog::Controllers::Tumblog
  class Topic
    include Tumblog::Action

    def call(params)
      ret = {}
      pid = params[:id]
      adapter = tumblog
      post = adapter.by_id(pid)
      raise "foo" unless params[:title]
      post.title = params[:title]
      pp post
      adapter.store(post)
      ret[:ok] = true
      self.body = ret.to_json
    end
  end
end
