module Backend::Controllers::Snippets
  class Create
    include Api::Action
    expose :snippet

    def call(params)
      pp params

      errors = {}
      fs = [:ident, :content].map do |f|
        fc = params[f]
        if fc.to_s.strip.empty?
          errors[f] = "empty"
          nil
        else
          [f, fc]
        end
      end
      fs = Hash[*fs.compact.flatten]

      if fs.size == 2
        ext = params[:extension].to_sym != :haml ? :markdown : :haml
        adapter = Habitat.adapter(:snippets)
        pp fs
        snippet = adapter.create(fs[:ident], fs[:content])
        pp snippet
      end
      
    end
  end
end
