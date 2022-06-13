module Backend::Controllers::Tumblog
  class Destroy
    include Backend::Action

    def call(params)
      ret = {}
      pid = params[:id]
      adapter = tumblog
      post = adapter.by_id(pid)
      adapter.destroy(post)
      # adapter.store(post)
      # ret[:ok] = true
      self.body = ret.to_json
    end
  end
end
