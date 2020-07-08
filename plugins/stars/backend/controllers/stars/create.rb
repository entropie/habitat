module Backend::Controllers::Stars
  class Create
    include Api::Action
    expose :star

    def call(params)
      adapter = Habitat.adapter(:stars)
      if request.post?
        star = adapter.create(1,2,3,4)
      end
    end
  end
end
