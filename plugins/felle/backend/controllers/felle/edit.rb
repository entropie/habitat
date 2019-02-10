module Backend::Controllers::Felle
  class Edit
    include Api::Action
    include ::Felle::ControllerMethods

    expose :fell

    def call(params)
      @fell = nil

      do_store = false

      if params[:create]
        @fell = create_fell_from_params(params)
        do_store = true
      else
        @fell = felle.find(params[:slug])
      end
      
      if @fell
        if request.post?
          @fell = update_fell_from_params(@fell, params)

          pimg = params[:panorama_image]
          if pimg
            felle.upload_header(@fell, pimg[:tempfile])
          end

          images = params[:gallery_images]
          if images and images.size > 0
            images.each do |uploaded_image|
              felle.upload(@fell, uploaded_image[:tempfile])
            end
          end
          do_store = true
        end

        if do_store
          felle do |f|
            f.store(@fell)
          end
        end
      end

    end
  end
end
