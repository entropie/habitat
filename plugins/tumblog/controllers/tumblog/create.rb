module Tumblog::Controllers::Tumblog
  class Create
    include Tumblog::Action

    def call(params)
      ret = {}
      content = params[:s]
      adapter = Habitat.adapter(:tumblog).with_user(session_user)
      post = adapter.create(:content => content)

      post.private = 1 if post.handler.create_interactive?

      post.handler.process!
      adapter.store(post)

      if post.handler.create_interactive?
        
        redirect_to Backend.routes.tumblogEdit_path(post.id)
      end


      ret[:ok] = true
      self.body = ret.to_json
    end
  end
end
