module Backend::Controllers::Felle
  class Edit
    include Api::Action
    include ::Felle::ControllerMethods

    expose :fell

    def call(params)
      if params[:create]
        @fell = create_fell_from_params(params)
        felle do |f|
          f.store(@fell)
        end
      else
        @fell = felle.find(params[:slug])

        pimg = params[:image]

        
        if request.post?
          @fell = update_fell_from_params(@fell, params)

          if pimg
            felle.upload(@fell, pimg[:tempfile])
          end

          felle do |f|
            f.store(@fell)
          end
        end
      end

    end
  end
end