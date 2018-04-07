module Blog

  class Image

    attr_reader :path, :basename, :dirname
    
    def initialize(path)
      @path = path
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
      FileUtils.mkdir_p(post.datadir("image"))
      FileUtils.cp(@path, File.join(post.datadir("image"), filename), :verbose => true)
      @dirname = File.join(post.slug, "image")
      @basename = filename
      remove_instance_variable("@path")
      self
    end

    def path
      File.join(dirname, basename)
    end

    def url
      File.join("/attachments", dirname, basename)
    end

    def to_html(opts = {})
      ret = ""

      cls = "post-image "
      cls << opts[:class] if opts[:class]
      
      ret << "<img src='%s' class='%s' />" % [url, cls]
      ret
    end
    
  end  
end
