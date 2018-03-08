module Diary

  module Renderer
    class BaseRenderer
      attr_reader :sheet
      attr_reader :result

      def initialize(sheet)
        @sheet = sheet
      end

      def snippet_renderer
        [ Snippets::SheetReferences ]
      end

      def content
        @sheet.content.dup
      end

      def render(renderer = snippet_renderer)
        Diary.log "starting rendering #{PP.pp(renderer, "")}"
        @result = @sheet.content.dup
        renderer.each do |snippet|
          @result = snippet.new(content).render
        end
        @result
      end
    end

    
    class HTML < BaseRenderer
    end
  end
end
