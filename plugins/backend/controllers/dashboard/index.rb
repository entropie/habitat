module Backend::Controllers::Dashboard
  class Index
    include Backend::Action

    def call(params)
      Habitat.plugin_enabled?(:snippets) do
        redirect_to routes.snippets_path
      end
    end
  end
end
