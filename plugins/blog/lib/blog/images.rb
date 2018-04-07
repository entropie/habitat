module Blog

  class Image

    attr_reader :basename, :dirname
    
    def initialize(basename)
      @basename = basename
    end

    def written?
      return false if @basename.split("/")[1] == "tmp"
      true
    end

    def copy_to(post)
      filename = Digest::SHA1.hexdigest(File.new(@basename).read) + ::File.extname(@basename)
      target = post.datadir("image", filename)
      FileUtils.mkdir_p(post.datadir("image"))
      FileUtils.cp(@basename, post.datadir("image", filename), :verbose => true)
      @dirname = post.datadir("image")
      @basename = filename
    end

    def path
      File.join(dirname, basename)
    end

    def url
      File.join("/attachments", dirname.gsub(Habitat.quart.media_path("data"), ""), basename)
    end

    def to_html
      ret = ""

      ret << "<img src='%s' class='post-image img-rounded' />" % [url]
      ret
    end
    
  end  
end
