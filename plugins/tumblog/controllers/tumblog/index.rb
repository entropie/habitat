module Backend::Controllers::Tumblog
  class Index
    include Backend::Action

    def call(params)
      posts = tumblog.entries.sort_by{|p| p.updated_at }.reverse
      self.body = {:entries => posts}.to_json
    end
  end
end
