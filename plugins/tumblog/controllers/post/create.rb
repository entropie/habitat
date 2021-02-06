module Api::Controllers::Post
  class Create
    include Api::Action

    def call(params)
      ret = {}
      content = params[:s]
      adapter = Habitat.adapter(:tumblog).with_user(session_user)
      post = adapter.create(:content => content)
      post.handler.process!
      adapter.store(post)
      ret[:ok] = true
      self.body = ret.to_json
    end
  end
end
