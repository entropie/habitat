module Felle
  class Fell
    
    class Image

      attr_accessor :path, :basename, :dirname
      attr_accessor :fell

      def self.from_datadir(fell, image_path)
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

      def copy_to(fell, fn = nil)
        fn = Digest::SHA1.hexdigest(File.new(@path).read) unless fn
        filename =  fn + ::File.extname(@path)
        target = fell.datadir("images", filename)
        
        FileUtils.mkdir_p(fell.datadir("images"), :verbose => true)
        FileUtils.cp(@path, fell.datadir("images", filename), :verbose => true)
        @dirname = File.join(fell.slug, "images")
        @basename = filename
        self
      end

      def header?
        basename =~ /^header/
      end

      def path
        File.join(dirname, basename)
      end

      def fullpath
        @fell.datadir("..", dirname, basename)
      end

      def url
        File.join("/attachments", dirname, basename)
      end

      def dimensions
        Dimensions.dimensions(fullpath)
      end

      def to_html(opts = {})
        ret = ""

        cls = "fell-image "
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
  
end
