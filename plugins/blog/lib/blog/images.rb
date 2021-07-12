module Blog

  class Image

    attr_accessor :path, :basename, :dirname
    attr_accessor :post

    def self.from_datadir(post, image_path)
      ret = new
      *ret.dirname, ret.basename = *image_path.split("/").last(3)
      ret.dirname = ret.dirname.join("/")
      ret
    end
    
    def initialize(path = nil)
      @path = path if path
    end

    def written?
      if basename and dirname
        return true
      else
        false
      end
    end

    def copy_to(post)
      filename = Digest::SHA1.hexdigest(File.new(@path).read) + ::File.extname(@path)
      target = post.datapath("image", filename)
      FileUtils.mkdir_p(post.datapath("image"), :verbose => true)
      FileUtils.cp(@path, post.datapath("image", filename), :verbose => true)
      @dirname = File.join(post.slug, "image")
      @basename = filename
      remove_instance_variable("@path")
      self
    end

    def path
      File.join(dirname, basename)
    end

    def fullpath
      File.join(Habitat.adapter(:blog).path, @post.datadir("..", dirname, basename))
    end

    def css_background_defintion
      retstr = "background-image: url(%s)" % url
      if Habitat.quart.plugins.enabled?(:webp)
        extend(Webp)
        Webp.encode(fullpath)
        retstr << ";background-image: url(%s)" % webp_url
      end
      retstr
    end

    def http_path(*args)
      File.join("/attachments", dirname, basename)
    end
    
    def url
      http_path
    end

    def dimensions
      Dimensions.dimensions(fullpath)
    end

    def to_html(opts = {})
      ret = ""

      cls = "post-image "
      cls << opts[:class] if opts[:class]
      
      ret << "<img src='%s' class='%s' />" % [url, cls]
      ret
    end

    def alignment
      w,h = dimensions
      if h > w
        :vertical
      else
        :horizontal
      end
    end
    
  end  
end
