module Blog

  def self.templates(path = nil)
    Templates::Templates.read(path)
  end

  module Templates

    class Templates < Hash
      attr_reader :path
      def initialize(path)
        @path = File.expand_path(path)
      end
      
      def self.read(path)
        new(path).read
      end

      def read
        Dir.glob("%s/*" % path).each do |tmpl_path|
          template = Template.new(tmpl_path)
          self[template.identifier] = template
        end
        self
      end
    end

    class Template
      attr_reader :path, :target, :result

      def initialize(path)
        @path = path
      end

      def identifier
        @identifier ||= File.basename(path).to_sym
      end

      def apply(obj)
        @target = obj
        self
      end

      def title
        target.title
      end

      def content
        target.content
      end

      def root(*args)
        File.join(path, *args)
      end

      def get_css
        css = []
        Dir.glob(root + "/*.css").each do |cssfile|
          css << File.readlines(cssfile).join << "\n"
        end
        css.join
      end

      def styles
        get_css
      end

      def javascript
        script = []
        root("javascript")
        Dir.glob(root + "/*.js").each do |scriptfile|
          script << File.readlines(scriptfile).join << "\n"
        end
        script
      end

      def images
        target.images
      end

      def ruby
        root("#{identifier}.rb")
      end

      # def template
      #   root("#{identifier}.haml")
      # end

      def compile
        @result, @javascript, @styles = nil
        
        a = eval(File.readlines(ruby).join, binding)
        self
      end
    end

  end
  
end
