module Backend::Controllers::T
  class Edit
    include Api::Action
    expose :trans
    def call(params)
      @trans = T.to_a[params[:slug]]
    end
  end
end
