module Pager

  class PagerNew
    attr_reader :params, :list, :link_proc
    attr_reader :pager
    attr_accessor :max


    def self.icons=(hsh)
      @icons = hsh
    end
    
    def self.icons
      @icons || ::Pager::Pager.icons
    end

    def icons
      self.class.icons
    end

    MAX = 10

    def max
      (@max || C[:pager] || MAX).to_i
    end

    class PagerArray

      attr_reader :current_page

      def initialize(array, current_page, limit, pager)
        @array, @current_page, @limit, @pager = array, current_page, limit, pager
      end

      def page_count
        pages, rest = @array.size.divmod(@limit).first
        rest == 0 ? pages : pages + 1
        
      end
      
      def size
        @array.size
      end

      def to_a
        @array
      end

      def empty?
        @array.empty?
      end
    end


    class PagerItems < Array
    end


    def self.paginate(params, list, m = max)
      new(params, list, m)
    end

    def initialize(params, list, m = self.max)
      @limit = m
      @params, @list = params, list
      @page = params[:page] && params[:page].to_i || 1
      @pager = PagerArray.new(@list, @page, m, self)
    end

    def limit
      @limit
    end
    
    def link_proc=(obj)
      @link_proc = obj
    end

    def current_page
      @pager.current_page
    end

    def size
      @pager.size
    end

    def empty?
      size == 0
    end

    def each(&blk)
      items_for(current_page).each(&blk)
    end

    def current_items
      items_for(current_page)
    end

    def items_for(pagenr)
      from = ((pagenr - 1) * @limit)
      to   = from + @limit
      @list[from...to]
    end

    def collect
      items = PagerItems.new

      items << PagerNavigationItem.new(value: 1, text: "fbackward", pager: self)
      items << PagerNavigationItem.new(value: [@page - 1, 1].max, text: "backward", pager: self)

      center = pager.current_page

      (1..pager.page_count).each_with_index do |pgnr|
        if [1, pager.page_count].include?(pgnr) or
          [center - 1, center, center + 1, center + 2].include?(pgnr)

          items << PagerItem.new(value: pgnr, pager: self)
        else
          items << PagerSpacer.new(value: pgnr, pager: self)
        end
      end

      items << PagerNavigationItem.new(value: @page + 1, text: "forward", pager: self)
      items << PagerNavigationItem.new(value: pager.page_count, text: "fforward", pager: self)


      # iterate over entire list to find multiple succeeding spacer items and flatten them
      cleaned_items = PagerItems.new
      items.each_with_index do |itm, index|
        if itm.kind_of?(PagerSpacer)
          if items[index-1].kind_of?(PagerSpacer) or items[index+1].kind_of?(PagerSpacer)
            # make sure we only have one spacer item
            if not items[index-1].kind_of?(PagerSpacer)
              cleaned_items << itm
            end
          else
            cleaned_items << itm.to_page_item
          end
        else
          cleaned_items << itm
        end
      end
      cleaned_items
    end

    def to_html
      items = collect
      ret = ""
      
      items.each do |itm|
        ret << itm.to_html.to_s
      end
      "<ul class='pager'>%s</a>" % ret
    end

    alias :navigation :to_html
    


    class PagerItem

      include Hanami::Helpers::HtmlHelper
      
      attr_accessor :text, :value, :pager, :link_proc

      def initialize(text: nil, value:, pager:)
        @text = text
        @value = value
        @pager = pager
      end

      def css_cls
        act = active? ? " active" : ""
        "page-item%s%s" % [(disabled? ? " disabled" : ""), act]
      end

      def active?
        @pager.current_page == @value
      end

      def to_html
        pg = @pager
        val = value
        html.li("class": css_cls) do
          if disabled?
            span("data-href" => pg.link_proc.call(val)) { @text||val }
          else
            a(:href => pg.link_proc.call(val)) { @text||val }
          end
        end
      end

      def disabled?
        return true if active?
        return true if @value > pager.pager.page_count
        return false
      end

      def inspect
        val = @value || ""
        act = (active? and not kind_of?(PagerNavigationItem)) ? "*" : " "
        "(%3s%s) (%s) [%s] -- %s" % [val, act, css_cls, text, pager.items_for(@value)]
      end
    end

    class PagerSpacer < PagerItem
      def css_cls
        "page-item page-spacer"
      end

      def inspect
        "..."
      end

      def to_html
        html.li("class": css_cls){
          "..."
        }
      end

      def to_page_item
        PagerItem.new(value: value, text: text, pager: pager)
      end
    end

    class PagerNavigationItem < PagerItem

      def initialize(value:, text:, pager:)
        @value = value
        @text = text
        @pager = pager
      end

      def css_cls
        "page-item pager-navigation"
      end

      def to_html
        pg = @pager
        val = value
        icnspn = html.span("class" => @pager.icons[@text.to_sym] || @text)
        html.li("class": css_cls) do
          if disabled?
            span("ddddata-href" => pg.link_proc.call(val)) { icnspn }          
          else
            a(:href => pg.link_proc.call(val)) { icnspn }
          end
        end
      end
      
    end

  end

  class BackendPager < PagerNew
    def icons
      @icons || {
        :forward   => "glyphicon glyphicon-forward",
        :backward  => "glyphicon glyphicon-backward",
        :fforward  => "glyphicon glyphicon-fast-forward",
        :fbackward => "glyphicon glyphicon-fast-backward",
      }
    end
  end

end
