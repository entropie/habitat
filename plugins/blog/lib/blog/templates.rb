module Blog

  def self.templates(path = Blog::TEMPLATE_PATH)
    Templates::Templates.read(path)
  end

  module Templates

    DEFAULT_TEMPLATE = :prettyok

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
      attr_reader :path, :target, :result, :styles, :javascript

      OPTIONS = {
        :sass => {},
        :haml => {:footnotes => true, :foo => :bar}
      }

      def initialize(path)
        @path = path
      end

      def identifier
        @identifier ||= File.basename(path).to_sym
      end

      def apply(obj)
        Class.new(Template).new(path).apply_for(obj)
      end

      def apply_for(obj)
        @target = obj
        self
      end

      def title
        target.title
      end

      def markdown_renderer
        Redcarpet::Render::HTML
      end

      def content
        @content ||=
          begin
            Redcarpet::Markdown.new(markdown_renderer, OPTIONS[:haml]).render(target.content)
          end
      end

      def root(*args)
        File.join(path, *args)
      end

      def get_css
        get_files_from_glob("css") do |cssfile|
          File.readlines(cssfile).join << "\n"          
        end
      end

      def get_sass
        get_files_from_glob("sass") do |cssfile|
          Sass::Engine.new(File.readlines(cssfile).join, OPTIONS[:sass]).render
        end
      end

      def styles
        get_css + get_sass 
      end

      def javascript
        root("javascript")
        get_files_from_glob("js") do |scriptfile|
          File.readlines(scriptfile).join << "\n"
        end
      end

      def images
        target.images
      end

      def ruby
        root("#{identifier}.rb")
      end

      def compile(params)
        @result, @javascript, @styles = nil

        @javascript = javascript
        @styles     = styles
        a = eval(File.readlines(ruby).join, binding)
        self
      end


      def get_files_from_glob(glob, ret = [])
        ret = []
        Dir.glob(root + "/*." + glob).each do |globfile|
          ret << yield(globfile)
        end
        ret.join
      end
      private :get_files_from_glob

    end

  end
  
end
