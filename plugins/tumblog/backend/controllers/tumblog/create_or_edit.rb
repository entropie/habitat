module Backend::Controllers::Tumblog
  class CreateOrEdit
    include Backend::Action

    include ::Tumblog::ControllerMethods

    expose :id, :post
    
    def call(params)

      @post = tumblog.by_id(params[:id])
      adapter = Habitat.adapter(:tumblog).with_user(session_user)


      if not @post and request.post?
      end

      @id = @post.id if @post

      return unless request.post?


      needs_processing = @post.update(params.to_hash)
      @post.handler.process! # if needs_processing
      adapter.update(@post)

    end
  end
end
