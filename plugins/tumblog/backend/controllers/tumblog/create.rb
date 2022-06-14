module Backend::Controllers::Tumblog
  class Create
    include Backend::Action

    def call(params)
      ret = {}

      return unless request.post?
      content = params[:content]
      adapter = Habitat.adapter(:tumblog).with_user(session_user)
      post = adapter.create(:content => content)
      post.handler.process!
      adapter.store(post)
      ret[:ok] = true
      redirect_to routes.tumblogShow_path(post.id)
    end
  end
end
