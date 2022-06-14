module Backend::Controllers::Tumblog
  class CreateOrEdit
    include Backend::Action

    include ::Tumblog::ControllerMethods

    expose :id, :post
    
    def call(params)

      @post = tumblog.by_id(params[:id])
      @id = @post.id if @post
    end
  end
end
