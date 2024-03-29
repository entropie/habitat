module Tumblog::Controllers::Tumblog
  class Index
    include Tumblog::Action

    def call(params)
      posts = tumblog.entries.sort_by{|p| p.updated_at }.reverse
      self.body = {:entries => posts.map{ |p| p.to_hash }}.to_json
    end
  end
end
