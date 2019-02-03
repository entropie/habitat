module Galleries

  module Database

    extend Habitat::Database

    class Adapter

      class File < Habitat::Database::Adapter

        attr_reader :path

        def initialize(path)
          @path = path
          @user = nil
        end

        def repository_path(*args)
          ::File.join(::File.realpath(path), "galleries", *args)
        end

        def find_or_create(gallery_ident, user = nil)
          gallery = Gallery.new(gallery_ident)
          gallery.adapter = self
          gallery.user = user
          gallery
        end

        def transaction(gallery, &blk)
          log :info, "gallery:#{gallery.ident} transaction starting..."
          g = yield gallery
          gallery.write_metadata
          log :info, "gallery:#{gallery.ident} transaction finish"
          g
        end

      end
      
    end
    
  end
  
end
