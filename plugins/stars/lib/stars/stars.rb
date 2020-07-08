# coding: utf-8
module Stars

  DEFAULT_ADAPTER = :File


  class StarAlreadyExist < RuntimeError
  end

  module StarsViewMethods
    def Star(arg, env = nil)
      Habitat.adapter(:stars).select(arg, env || locals[:params])
    end
  end

  module StarsControllerMethods
  end


  def self.all
    Habitat.adapter(:stars).stars
  end

  class Stars < Array

    def initialize(arr)
      push(*arr)
    end

    def [](obj)
      ident = ::Habitat::Database::make_slug(obj.to_s)
      ret = select{|s| s.ident == ident}
      return ret.first if ret
    end
  end

  class Star

    attr_reader   :ident
    attr_accessor :path

    attr_accessor :content
    attr_accessor :image
    attr_accessor :stars

    def initialize(ident, stars, content, image)
      @ident = ident
      @stars = stars
      @content = content
      @image = image
    end

    def filename
      "%s.star.%s" % [ident, "yaml"]
    end

    def self.for(filename)
      YAML::load(File.readlines(filename).join)
    end
    
    def self.ident_from(filename)
      filename.split(".").first.to_sym
    end

    def destroy
      adapter.destroy(self)
    end

    def exist?
      File.exist?(adapter.repository_path(filename))
    end
  end

  class NotExistingStar < Star
    def read
      ""
    end
    def render
      "<span class='not-existing-star'><code>#{ident}</code> not exist</span>"
    end

    def exist?
      false
    end
  end
    
end
