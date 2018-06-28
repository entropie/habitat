module Api::Controllers::Post
  class Index
    include Api::Action

    def call(params)
      posts = tumblog.entries.sort_by{|p| p.updated_at }.reverse
      self.body = {:entries => posts}.to_json
    end
  end
end
