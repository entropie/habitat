module Blog

  def self.templates(path = Blog.template_path || Blog::TEMPLATE_PATH)
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

      def [](obj)
        super(obj.to_sym)
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

      def ==(obj)
        if obj.kind_of?(Template)
          return identifier == obj.identifier
        end
        identifier == obj.to_sym
      end

      def markdown_renderer
        Redcarpet::Render::HTML
      end

      def render_preview(user)
        post = Habitat.adapter(:blog).with_user(user) do |blog|
          blog.by_slug("preview")
        end
        #template = params[:t] || @post.template || C[:default_template]
        post.with_template(identifier).compile({})
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

      def get_sass
        File.readlines(root("screen.sass")).join
      end

      def get_css
        styles
      end

      def styles
        Sass::Engine.new(get_sass, OPTIONS[:sass]).render
      end

      def javascript
        File.readlines(root("javascript.js")).join
      end

      def images
        target.images
      end

      def ruby
        File.readlines(root("template.rb")).join
      end

      def compile(params)
        @result, @javascript, @styles = nil

        @javascript = javascript
        @styles     = styles
        a = eval(ruby, binding)
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

      def with_operator
        wo = self.extend(TemplateOperations)
        yield wo if block_given?
        wo
      end
    end



    module TemplateOperations
      include Habitat::Mixins::FU

      def valid?(hash)
        valid = true
        hash.each_pair do |h,k|
          valid = false if h.nil? or k.nil?
        end
        valid
      end

      def update(ruby:, javascript:, sass:)
        hsh = {"template.rb" => ruby,
               "javascript.js" => javascript,
               "screen.sass" => sass}
        
        raise "invalid #{PP.pp(hsh, "")}" unless valid?(hsh)
        hsh.each_pair do |file, cnts|
          write(root(file), cnts)
        end
        self
      end

      def update_or_create(ruby:, javascript:, sass:)
        mkdir_p(root)
        update(ruby: ruby, javascript: javascript, sass: sass)
        self
      end

      def rename(newident)
      end

      def duplicate(newident)
      end
    end
    
    class TemplateDummy < Template
      include TemplateOperations

      def initialize(ident)
        @identifier = ident.to_sym
        @path = Blog.template_path(ident)
      end

    end


  end
  
end
