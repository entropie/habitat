module Backend::Controllers::T
  class Edit
    include Api::Action
    expose :trans
    def call(params)
      @trans = "your mom"
    end
  end
end
