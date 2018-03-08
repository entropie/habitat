module Diary
  
  module Snippets
    class Snippet

      attr_reader :content
      attr_reader :result
      
      def initialize(content)
        @content = content
        @result  = @content.dup
      end

      def render
        Diary.log "using renderer #{self.class}"
        parse
      end

      def grep(arg, &blk)
        @result.gsub!(arg, &blk)
        self
      end

      def parse
        raise "not implemented"
      end
    end

    class SheetReferences < Snippet
      def parse
        grep(/(\#\w+)/) do |w|
          r = "(((#{w})))"
          Diary.log("#{w} => #{r}")
          r
        end
      end
    end
  end 
end
