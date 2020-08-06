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
      return ret.first if ret && ret.first
      return NotExistingStar.new(obj) if obj
    end
  end

  class Star

    attr_reader   :ident
    attr_accessor :path

    attr_accessor :content
    attr_accessor :image
    attr_accessor :stars
    attr_accessor :url
    attr_accessor :name

    def initialize(name_and_ident, stars = nil, content = nil)
      slug_ident = ::Habitat::Database::make_slug(name_and_ident)
      @ident = slug_ident
      @name = name_and_ident
      @stars = stars
      @content = content
      @image = nil
    end

    def to_hash
      { :ident => @ident,
        :name => @name,
        :path => @path,
        :content => content,
        :stars => stars,
        :url => url,
        :image => image
      }
    end

    def stars=(str_or_int)
      @stars = str_or_int.to_i
    end

    def merge(hsh)
      hsh.each_pair do |k, v|
        send("#{k}=", v)
      end
      self
    end

    def filename
      "%s.star.%s" % [ident, "yaml"]
    end

    def self.image2base64(path)
      if ::File.exist?(path)
        ::File.open(path, 'rb') do |img|
          return 'data:image/jpeg;base64,' + Base64.strict_encode64(img.read)
        end
      else
        path
      end
    end

    def image=(imgfile_or_base64str)
      @image = Star.image2base64(imgfile_or_base64str)
      self
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
      File.exist?(Habitat.adapter(:stars).repository_path(filename))
    end
  end

  class NotExistingStar < Star

    def initialize(ident)
      super(ident, 5, "not existing")
    end

    def create(hsh)
      ret = Star.new(ident)
      ret.merge(hsh)
      ret
    end

    def render
      "<span class='not-existing-star'><code>#{ident}</code> not exist</span>"
    end

    def exist?
      false
    end
  end
    
end
