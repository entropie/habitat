module Backend::Controllers::Galleries
  class Upload
    include Backend::Action
    include Galleries::ControllerMethods

    def call(params)
      @gallery = galleries.find_or_create(params[:slug])

      if request.post?
        files = params[:file]
        unless files.empty?
          filesarr = files.map{ |f| f[:tempfile].path }
          galleries.transaction(@gallery) do |g|
            g.add(filesarr)
          end
          redirect_to routes.gallery_path(@gallery.ident)
        end
      end
    end
  end
end
