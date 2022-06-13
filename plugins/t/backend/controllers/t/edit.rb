module Backend::Controllers::T
  class Edit
    include Backend::Action
    expose :trans
    def call(params)
      @trans = T[params[:slug]]
    end
  end
end
