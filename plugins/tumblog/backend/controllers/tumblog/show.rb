module Backend::Controllers::Tumblog
  class Show
    include Backend::Action

    include ::Tumblog::ControllerMethods

    expose :post

    def call(params)
      @post = tumblog.by_id(params[:id])
    end
  end
end
