module Backend::Controllers::Blog
  class Template
    include Api::Action

    expose :blemplate

    def call(params)
      @blemplate = Blog.templates[params[:slug]]
    end
  end
end
