module Snippets

  DEFAULT_ADAPTER = :File

  def self.[](obj)
    Habitat.adapter(:snippets)[obj]
  end

  def self.all
    Habitat.adapter(:snippets).snippets
  end

  module SnippetCreater
  end

  class Snippets < Array

    def initialize(arr)
      push(*arr)
    end

    def [](obj)
      ident = obj.to_sym
      ret = select{|s| s.ident == ident}
      return ret.first if ret
      nil
    end
  end

  class Snippet

    attr_reader :ident
    attr_accessor :path

    def initialize(ident)
      @ident = ident
    end

    def filename(ext)
      "%s.snippet.%s" % [ident, ext]
    end

    def self.ident_from(filename)
      filename.split(".").first.to_sym
    end

    def self.for(snippet_full_path)
      snippet_filename = File.basename(snippet_full_path)
      clz =
        if snippet_filename =~ /\.haml$/
          HAMLSnippet
        else
          MarkdownSnippet
        end
      ret = clz.new(ident_from(snippet_filename))
      ret.path = snippet_full_path
      ret
    end

    def read
      @content = File.readlines(path).join
    end

    def content
      read
    end

    def to_s
      read
    end
  end

  class MarkdownSnippet < Snippet
    def filename
      super("markdown")
    end

    def render
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true, footnotes: false)
      super(markdown.render(to_s))
      "lala"
    end
  end

  class HAMLSnippet < Snippet
    def filename
      super("haml")
    end

    def render
      "%s" % Haml::Engine.new(to_s).render
    end
  end

end
