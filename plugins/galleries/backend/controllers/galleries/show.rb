module Backend::Controllers::Galleries
  class Show
    include Backend::Action
    include Galleries::ControllerMethods

    expose :gallery
    
    def call(params)
      @gallery = galleries.find_or_create(params[:slug])
    end
  end
end
