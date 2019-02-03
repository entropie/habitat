module Backend::Controllers::Galleries
  class Create
    include Api::Action
    include Galleries::ControllerMethods
    
    expose :gallery
    
    def call(params)
      name = params[:name]
      if request.post? and not name.to_s.empty?
        gal = galleries.find_or_create(name)
        galleries.transaction(gal) do |g|
        end

      end

      
    end
  end
end
