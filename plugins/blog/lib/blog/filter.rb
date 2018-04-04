module Blog

  class Filter

    attr_reader :post
    
    class NokogiriFilter
      def initialize(html)
        @content = Nokogiri::HTML.fragment(html)
      end
      def setup(post)
        @content.to_html
      end
    end

    class EngineCache < NokogiriFilter

      attr_reader :written, :content

      def filename(str)
        [self.class.to_s.split("::").last.downcase, str].join("_") + ".html"
      end

      def written?
        @written
      end

      def setup(post)
        target_file = post.attachment_path(filename("post"))
        unless File.exist?(target_file)
          @written = true
          ret = super
          FileUtils.mkdir_p(File.dirname(target_file), :verbose => true)
          File.open(target_file, "w+"){|fp|
            fp.puts(ret)
          }
          @content = ret
        else
          @content = File.readlines(target_file).join
        end
        self
      end
    end

    class ImageFilter
      def initialize(html)
        @html = html
      end

      def filename(str)
        [self.class.to_s.split("::").last.downcase, str].join("_") + ".html"
      end

      def setup(post)
        @html
      end

    end

    class FlickrFilter < ImageFilter
      def setup(post)
        @html.gsub!(/(\[flickr: (\d+) ?(.*))\]/) do |match|
          flickrid = $2.to_i
          rest = $3
          rest = :large unless rest or rest.strip.empty?
          FI(flickrid, rest.to_sym)
        end
        @html
      end
    end

    class FlickrGroup < ImageFilter

      def setup(post)
        @html.gsub!(/(\[flickgr: (.*)\])/) do |match|
          flickrids = *$2.split(" ").map(&:to_i)
          ret = "<div class='flickr-group-box'>%s</div>"
          ret % flickrids.map{|fid| FI(fid, :small) }.join
        end
        @html
      end
      
    end

    # class SideComments < NokogiriFilter
    #   def setup(post)
    #     @content.css("p, ul, ol").each_with_index do |node, index|
    #       node["data-id"] = index
    #     end
    #     super
    #   end
    # end

    class TopicAnchors < NokogiriFilter
      def setup(post)
        @content.css("h1,h2,h3,h4,h5,h6").each_with_index do |node, index|
          ident = Blogs.to_slug(node.text)
          node["id"] = ident
          #node["data-topic-slug"] = ident
        end
        super
      end
    end

    class Paragraphing < NokogiriFilter
      def setup(post)
        @content.css("p, ul, ol").each_with_index do |node, index|
          node["class"] = "post-text-block"
        end
        super
      end
    end

    class HTMLFilter < Filter
      def apply!
        ret = post.content

        #ec = EngineCache.new(ret)
        #ec = ec.setup(post)
        if HTMLFilter.clear!(post)
          ret = Blogs.with_markdown(ret)
          # ret = FlickrFilter.new(ret).setup(post)
          # ret = FlickrGroup.new(ret).setup(post)
          # #ret = SideComments.new(ret).setup(post)
          # ret = TopicAnchors.new(ret).setup(post)
          # ret = Paragraphing.new(ret).setup(post)
          # ret = EngineCache.new(ret).setup(post).content
          ret
        else
          ec.content
        end
      end

    end

    def initialize(post)
      @post = post
    end

    def self.clear!(post)
      Dir.glob("#{post.attachment_path}/*.*").each do |f|
        FileUtils.rm(f, :verbose => true)
      end
    end

    def self.apply(what, post)
      HTMLFilter.new(post).apply!
    end
  end


  
end
