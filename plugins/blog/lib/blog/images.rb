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

  end
  
end
