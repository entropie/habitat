module Backend::Controllers::Tumblog
  class Create
    include Backend::Action

    expose :post
    
    def call(params)
      ret = {}

      return unless request.post?
      content = params[:content]
      tags = Tumblog.tagify(params[:tags])
      title = params[:title]
      adapter = Habitat.adapter(:tumblog).with_user(session_user)
      post = adapter.create(:content => content, :tags => tags, :title => title)
      post.private!
      post.handler.process!
      adapter.store(post)
      ret[:ok] = true
      redirect_to routes.tumblogShow_path(post.id)
    end
  end
end
