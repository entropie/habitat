module Backend::Controllers::Tumblog
  class Destroy
    include Backend::Action

    def call(params)
      ret = {}
      pid = params[:id]
      adapter = Habitat.adapter(:tumblog).with_user(session_user)
      post = adapter.by_id(pid)
      adapter.destroy(post)
      # adapter.store(post)
      ret[:ok] = true
      redirect_to back
    end
  end
end
