module Blog

  class Filter

    TO_HTML = -> (content) {
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true, footnotes: true)
        markdown.render(content)
    }
    

    attr_reader :post

    def self.filter_constants
      @filter_constants ||= []
    end
    
    def self.inherited(o)
      filter_constants << o
    end

    def initialize(post)
      @post = post
    end

    def apply(arg = nil)
      frt = if arg
              [arg]
            else
              Filter.filter_constants
            end

      res = post.content.dup
      frt.each do |fc|
        begin
          Habitat.log :debug, "filter: #{fc} for #{post.id}"
          res = fc.new(post).filter(res)
        rescue NameError
          Habitat.log :warn, "something went wrong with #{fc}"
        end
      end
      res
    end

    def nokogiri(str = nil)
      ::Nokogiri::HTML::fragment(str || post.content)
    end

    class Nokogiri
      def initialize(post)
        @post = post
      end

      def filter
        post.nokogiri
      end
    end


    class Markdown < Filter
      def filter(str)
        TO_HTML.call(str)
      end
    end

    
    class FlickrImg < Filter
      def filter(str)
        ret = nokogiri(str)
        ret.css("p").each_with_index do |node, index|
          node.text.scan(/(\[flickr: (\d+) ?(.*))\]/) do |match|
            flickrid = $2.to_i
            rest = $3
            rest = :large unless rest or rest.strip.empty?
            extend Flickr
            node.replace(FI(flickrid, rest.to_sym))
          end
        end
        ret.to_html
      end
    end

    
    class FlickrImgGroup < Filter
      def filter(str)
        ret = nokogiri(str)
        ret.css("p").each_with_index do |node, index|
          node.text.scan(/(\[flickgr: (.*)\])/) do |match|
            flickrids = *$2.split(" ").map(&:to_i)
            sret = "<div class='flickr-group-box'>%s</div>"
            extend Flickr
            node.replace(sret % flickrids.map{|fid| FI(fid, :small) }.join)
          end
        end
        ret.to_html
      end
    end
    
    
    class TopicAnchors < Filter
      def filter(str)
        ret = nokogiri(str)
        ret.css("h1,h2,h3,h4,h5,h6").each_with_index do |node, index|
          ident = Post.make_slug(node.text)
          node["id"] = ident
        end
        ret.to_html
      end
    end
    

    class Paragraphing < Filter
      def filter(str)
        ret = nokogiri(str)
        ret.css("p, ul, ol").each_with_index do |node, index|
          node["class"] = "post-text-block"
        end
        ret.to_html
      end
    end
    
  end


  
end
