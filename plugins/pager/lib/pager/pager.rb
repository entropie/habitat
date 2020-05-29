
module Pager

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



  def self.paginate(params, list, max = nil)
    Pager.new(params, list, max)
  end
  
  class Pager
    include Hanami::Helpers::HtmlHelper

    attr_reader :params, :list, :link_proc
    attr_reader :pager
    attr_accessor :max

    MAX = 10

    def max
      (@max || C[:pager] || MAX).to_i
    end

    def initialize(params, list, m = max)
      m = max unless m
      @params, @list = params, list
      @page = params[:page] && params[:page].to_i || 1
      @pager = ArrayPager.new(list, @page, m)
    end

    def link(g, n, text = n, hash = {})
      text = text.to_s
      g.a({:href => link_proc.call(n) }){ text }
    end

    def link_proc=(obj)
      @link_proc = obj
    end

    def navigation(limit = 8)
      html.ul(:class => :pager) do
        if first_page?
          li(:class => "page-item disabled") {
            span(:class => 'first grey'){
              span(:class => "glyphicon glyphicon-fast-backward") {""}
            } }
          li(:class => "page-item disabled") {
            span(:class => 'previous grey'){ span(:class => "glyphicon glyphicon-backward") {""} } } 
        else
          li(:class => "page-item") { a(:href => link_proc.call(1)){ span(:class => "glyphicon glyphicon-fast-backward hl first")}}
          li(:class => "page-item") { a(:href => link_proc.call(prev_page||1)){ span(:class => "glyphicon glyphicon-backward hl previous")}}
        end

        lower = limit ? (current_page - limit) : 1
        lower = lower < 1 ? 1 : lower

        (lower...current_page).each do |n|
          li(:class => "page-item") { a(:href => n){ n } }
        end

        li(:class => "page-item active disabled") { span current_page }
        
        if last_page?
          li(:class => "page-item disabled") {
            span(:class => 'next grey'){ span(:class => "glyphicon glyphicon-fast-forward") {""} } }
          li(:class => "page-item disabled") {
            span(:class => 'next grey'){ span(:class => "glyphicon glyphicon-forward") {""} } } 
        elsif next_page
          higher = limit ? (next_page + limit) : page_count
          higher = [higher, page_count].min
          (next_page..higher).each do |n|
            li(:class => "page-item") {
              a(:href => link_proc.call(n)){ n }
            }
          end

          li(:class => "page-item") { a(:href => link_proc.call(next_page)){ span(:class => "glyphicon glyphicon-forward hl next")}}
          li(:class => "page-item") { a(:href => link_proc.call(page_count)){ span(:class => "glyphicon glyphicon-fast-forward hl last")}}
        end
      end
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
