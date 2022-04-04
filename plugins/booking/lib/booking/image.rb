module Booking
  class Events
    
    class Image

      attr_accessor :path, :basename, :dirname
      attr_accessor :event

      def self.from_datapath(event, image_path)
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

      def copy_to(event, fn = nil)
        fn = Digest::SHA1.hexdigest(File.new(@path).read) unless fn
        filename =  fn + ::File.extname(@path)
        target = event.datapath("images", filename)
        FileUtils.mkdir_p(event.datapath("images"), :verbose => true)
        FileUtils.cp(@path, event.datapath("images", filename), :verbose => true)
        remove_instance_variable(:@path)
        @dirname = event.relative_datapath
        @basename = filename
        self
      end

      def path
        File.join(dirname, basename)
      end

      def exist?
        File.exist?(fullpath)
      end

      def fullpath
        Habitat.quart.media_path(dirname, "images", basename)
      end

      def url
        File.join("/", dirname, "images", basename)
      end

      def http_path
        url
      end

      def dimensions
        Dimensions.dimensions(fullpath)
      end

      def to_html(opts = {})
        ret = ""

        cls = "ev-image "
        cls << opts[:class] if opts[:class]
        
        ret << "<img src='%s' class='%s' />" % [url, cls]
        ret
      end

      def css_background_definition
        retstr = "background-image: url(%s)" % url
        if Habitat.quart.plugins.enabled?(:webp)
          extend(Webp)
          retstr << ";background-image: url(%s)" % webp_url
        end
        retstr
      end

      def alignment
        w,h = dimensions
        if h > w
          :vertical
        else
          :horizontal
        end
      end

      def cleaned
        ret = self.class.new
        ret.dirname = dirname
        ret.basename = basename
        ret
      end
      
    end

    class NoImage < Image
      def initialize
        @path = nil
      end

      def url
        ""
      end

      def exist?
        false
      end
      
      def css_background_defintion
        ""
      end
      
    end


  end
  
end
