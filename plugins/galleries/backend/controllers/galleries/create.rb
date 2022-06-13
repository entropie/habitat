module Backend::Controllers::Galleries
  class Create
    include Backend::Action
    include Galleries::ControllerMethods
    
    expose :gallery
    
    def call(params)
      name = params[:name]
      if request.post? and not name.to_s.empty?
        gal = galleries.find_or_create(name)
        galleries.transaction(gal)
        redirect_to Backend.routes.gallery_path(gal.ident)
      end
    end
  end
end
