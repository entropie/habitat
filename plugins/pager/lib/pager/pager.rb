
module Pager


  # https://github.com/Ramaze/ramaze/blob/master/lib/ramaze/gestalt.rb
  class Gestalt
    attr_accessor :out
    def self.build(&block)
      self.new(&block).to_s
    end

    def initialize(&block)
      @out = []
      instance_eval(&block) if block_given?
    end

    def method_missing(meth, *args, &block)
      _gestalt_call_tag meth, args, &block
    end


    def p(*args, &block)
      _gestalt_call_tag :p, args, &block
    end


    def select(*args, &block)
      _gestalt_call_tag(:select, args, &block)
    end

    def _gestalt_call_tag(name, args, &block)
      if args.size == 1 and args[0].kind_of? Hash
        # args are just attributes, children in block...
        _gestalt_build_tag name, args[0], &block
      elsif args[1].kind_of? Hash
        # args are text and attributes ie. a('mylink', :href => '/mylink')
        _gestalt_build_tag(name, args[1], args[0], &block)
      else
        # no attributes, but text
        _gestalt_build_tag name, {}, args, &block
      end
    end

    def _gestalt_build_tag(name, attr = {}, text = [])
      @out << "<#{name}"
      @out << attr.map{|(k,v)| %[ #{k}="#{_gestalt_escape_entities(v)}"] }.join
      if text != [] or block_given?
        @out << ">"
        @out << _gestalt_escape_entities([text].join)
        if block_given?
          text = yield
          @out << text.to_str if text != @out and text.respond_to?(:to_str)
        end
        @out << "</#{name}>"
      else
        @out << ' />'
      end
    end

    def _gestalt_escape_entities(s)
      s.to_s.gsub(/&/, '&amp;').
        gsub(/"/, '&quot;').
        gsub(/'/, '&apos;').
        gsub(/</, '&lt;').
        gsub(/>/, '&gt;')
    end

    def tag(name, *args, &block)
      _gestalt_call_tag(name.to_s, args, &block)
    end


    def to_s
      @out.join
    end
    alias to_str to_s
  end # Gestalt



  class ArrayPager
    def initialize(array, page, limit)
      @array, @page, @limit = array, page, limit
      @page = page_count if @page > page_count
    end

    
    def size
      @array.size
    end

    def empty?
      @array.empty?
    end

    def page_count
      pages, rest = size.divmod(@limit)
      rest == 0 ? pages : pages + 1
    end

    def current_page
      @page
    end

    def next_page
      page_count == @page ? nil : @page + 1
    end

    def shift
      @array.shift
    end


    def prev_page
      @page <= 1 ? nil : @page - 1
    end

    def first_page?
      @page <= 1
    end

    def last_page?
      page_count == @page
    end

    def each(&block)
      from = ((@page - 1) * @limit)
      to = from + @limit

      a = @array[from...to] || []
      a.each(&block)
    end

    def each_with_index(&block)
      from = ((@page - 1) * @limit)
      to = from + @limit

      a = @array[from...to] || []
      a.each_with_index(&block)
    end

    include Enumerable
  end



  def self.paginate(params, list)
    Pager.new(params, list)
  end
  
  class Pager
    attr_reader :params, :list, :link_proc

    MAX = 10

    def max
      ret = C[:pager] or raise "page not set in config"
      ret.to_i
    rescue
      Habitat.log :info, "pager not set in config, using default (set: pager)"
      MAX
    end

    def initialize(params, list)
      @params, @list = params, list
      @page = params[:page] && params[:page].to_i || 1
      @pager = ArrayPager.new(list, @page, max)
    end

    def link(g, n, text = n, hash = {})
      text = text.to_s
      g.a({:href => link_proc.call(n) }){ text }
    end

    def link_proc=(obj)
      @link_proc = obj
    end


    def navigation(limit = 8)
      g = Gestalt.new
      g.ul :class => :pagination do
            
        if first_page?
          g.li(:class => "page-item disabled") {
            g.span(:class => 'first grey'){ g.span(:class => "glyphicon glyphicon-fast-backward") } }
          g.li(:class => "page-item disabled") {
            g.span(:class => 'previous grey'){ g.span(:class => "glyphicon glyphicon glyphicon-backward") } } 
        else
          g.li(:class => "page-item") { link(g, 1, '<span class="glyphicon glyphicon-fast-backward"></span>', :class => "page-item hl first") }
          g.li(:class => "page-item ") { link(g, prev_page, '<span class="glyphicon glyphicon-backward"></span>', :class => "page-item hl previous") }              
        end

        lower = limit ? (current_page - limit) : 1
        lower = lower < 1 ? 1 : lower

        (lower...current_page).each do |n|
          g.li(:class => "page-item") { link(g, n) }
        end

        g.li(:class => "page-item active disabled") { g.span current_page }
        
        if last_page?
          g.li(:class => "page-item disabled") {
            g.span(:class => 'next grey'){ g.span(:class => "glyphicon glyphicon-fast-forward") } }
          g.li(:class => "page-item disabled") {
            g.span(:class => 'next grey'){ g.span(:class => "glyphicon glyphicon-forward") } } 
        elsif next_page
          higher = limit ? (next_page + limit) : page_count
          higher = [higher, page_count].min
          (next_page..higher).each do |n|
            g.li(:class => "page-item") { link(g, n) }
          end
          g.li(:class => "page-item") { link(g, next_page,  '<span class="glyphicon glyphicon-forward"></span>', :class => "hl next") }
          g.li(:class => "page-item") { link(g, page_count, '<span class="glyphicon glyphicon-fast-forward"></span>', :class => "hl last") }              
        end
      end
      g.to_s
    end


    def each(&blk)
      @pager.each(&blk)
    end

    def page_count; @pager.page_count end
    def each(&block) @pager.each(&block) end
    def each_with_index(&block) @pager.each_with_index(&block) end
    def first_page?; @pager.first_page?; end
    def prev_page; @pager.prev_page; end
    def current_page; @pager.current_page; end
    def last_page; @pager.last_page; end
    def last_page?; @pager.last_page?; end
    def next_page; @pager.next_page; end
    def empty?; @pager.empty?; end
    def count; @pager.count; end
    def shift; @pager.shift; end
  end
  
end
