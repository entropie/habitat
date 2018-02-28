module Web::Controllers::Blog
  class Index
    include Web::Action
    include Hanami::Action::Session

    include Blog::Controller

    def call(params)
      p @post
    end
  end
end
