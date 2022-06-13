module Backend::Controllers::Galleries
  class Control
    include Backend::Action
    include Galleries::ControllerMethods

    expose :gallery

    def call(params)
      @gallery = galleries.find_or_create(params[:slug])

      if request.post?
        ident, hash = params[:ident], params[:hash]
        if not ident.empty?
          img = @gallery.images(hash)

          galleries.transaction(@gallery) do |g|
            g.set_ident(img, ident)
          end

          redirect_to routes.gallery_path(@gallery.ident)
        end
        
      end
    end
  end
end
