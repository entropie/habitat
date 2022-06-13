module Backend::Controllers::Blog
  class Template
    include Backend::Action

    expose :blemplate

    def call(params)
      @blemplate = Blog.templates[params[:slug]]
    end
  end
end
