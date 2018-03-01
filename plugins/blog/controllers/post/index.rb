module Web::Controllers::Blog
  class Index
    include Web::Action
    include Hanami::Action::Session

    include Blog::Controller

    expose :posts, :post

    def call(params)
    end
  end
end
