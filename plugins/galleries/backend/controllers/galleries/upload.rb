module Backend::Controllers::Galleries
  class Upload
    include Api::Action
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
        end
      end
    end
  end
end
