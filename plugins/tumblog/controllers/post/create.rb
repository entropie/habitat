module Api::Controllers::Post
  class Create
    include Api::Action

    def call(params)
      ret = {}
      content = params[:s]
      ret[:ok] = BackgroundJob.anytime do
        sleep 5
        adapter = Habitat.adapter(:tumblog).with_user(@token_user || session_user)
        post = adapter.create(:content => content)
        
        target_file = post.datadir(post.id + ".mp4")
        ret = YoutubeDL.download content, output: target_file
        adapter.store(post)
      end && :ya

      self.body = ret.to_json
    end
  end
end
