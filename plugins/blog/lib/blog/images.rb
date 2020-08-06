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
      target = post.datadir("image", filename)
      FileUtils.mkdir_p(post.datadir("image"), :verbose => true)
      FileUtils.cp(@path, post.datadir("image", filename), :verbose => true)
      @dirname = File.join(post.slug, "image")
      @basename = filename
      remove_instance_variable("@path")
      self
    end

    def path
      File.join(dirname, basename)
    end

    def fullpath
      @post.datadir("..", dirname, basename)
    end

    def to_webp
      name, extname = basename.split(".")
      webp_filename = File.join(File.dirname(fullpath), "%s.%s" % [name, "webp"])
      unless File.exist?(webp_filename)
        Habitat.log :debug, "blog:image generating webp for #{fullpath}"
        WebP.encode(fullpath, webp_filename)
      end
    end

    def url
      File.join("/attachments", dirname, basename)
    end

    def webp_url
      to_webp
      File.join("/attachments", dirname, basename.split(".").first + ".webp")
    rescue
      ""
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
