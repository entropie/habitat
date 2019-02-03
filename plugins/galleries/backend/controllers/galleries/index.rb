module Backend::Controllers::Galleries
  class Index
    include Api::Action
    include Galleries::ControllerMethods

    expose :all

    def call(params)
      @all = galleries.all
    end
  end
end
