module Backend::Controllers::Snippets
  class Snippet
    include Api::Action

    def call(params)
      p Backend
      p 23
    end
  end
end
