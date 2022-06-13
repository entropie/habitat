module Backend::Controllers::T
  class CreateOrEdit
    include Backend::Action
    expose :trans
    def call(params)
      @trans = T.to_a[params[:slug]]

      @trans = T.update_or_create(params.to_hash)

      redirect_to routes.tEdit_path(@trans.key)
      
    end
  end
end
