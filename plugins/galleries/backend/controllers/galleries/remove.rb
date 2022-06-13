module Backend::Controllers::Galleries
  class Remove
    include Backend::Action
    include Galleries::ControllerMethods

    def call(params)
      @gallery = galleries.find(params[:slug])
      @image = @gallery.images(params[:hash])

      galleries.transaction(@gallery) do |g|
        g.remove(@image)
      end
      redirect_to routes.gallery_path(@gallery.ident)
    end
  end
end
