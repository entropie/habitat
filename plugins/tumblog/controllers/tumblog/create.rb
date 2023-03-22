module Tumblog::Controllers::Tumblog
  class Create
    include Tumblog::Action

    def call(params)
      ret = {}
      content = params[:s]
      adapter = Habitat.adapter(:tumblog).with_user(session_user)
      
      post = adapter.create(:content => content)

      if post.handler.create_interactive?
        urlwohttp = post.content.dup.gsub(/^https?:\/\//, "").gsub(/\/$/, "")
        post.update(content: "[%s](%s)" % [urlwohttp, post.content])
        post.private!
      end
      
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
