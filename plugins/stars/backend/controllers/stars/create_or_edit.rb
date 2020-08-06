

module Backend::Controllers::Stars
  class CreateOrEdit
    include Api::Action
    expose :star

    def call(params)
      adapter = Habitat.adapter(:stars)
      @star = adapter.stars[params[:ident]]

      if request.post?
        errors = {}
        fs = [:ident, :content, :stars].map do |f|
          fc = params[f]
          if fc.to_s.strip.empty?
            errors[f] = "empty"
            nil
          else
            [f, fc]
          end
        end
        fs = Hash[*fs.compact.flatten]


        [:url, :name].each do |prm|
          fs[prm] = params[prm] if params[prm]
        end
        
        hparams = params.to_h
        imgh = hparams.delete(:image)
        fs[:image] = imgh[:tempfile] if imgh
        if fs.size >= 3
          @star = adapter.update_or_create(fs)
        end
      end

    end

  end
end
