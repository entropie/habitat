module Backend::Controllers::Stars
  class Create
    include Api::Action
    expose :star

    def call(params)
      adapter = Habitat.adapter(:stars)
      if request.post?

        hparams = params.to_h
        pimg = hparams.delete(:image)

        hparams[:image] = pimg[:tempfile]
        star = adapter.update_or_create(hparams)
      end
    end
  end
end

