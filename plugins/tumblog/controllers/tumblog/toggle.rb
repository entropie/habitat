module Tumblog::Controllers::Tumblog
  class Toggle
    include Tumblog::Action

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
      ret[:body] = ret.to_json
      ret[:ok] = true
      ret
    end
  end
end
