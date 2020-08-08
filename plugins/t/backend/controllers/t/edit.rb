module Backend::Controllers::T
  class Edit
    include Api::Action
    expose :trans
    def call(params)
      @trans = T[params[:slug]]
    end
  end
end
