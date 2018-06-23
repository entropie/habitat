# coding: utf-8
module Snippets

  DEFAULT_ADAPTER = :File

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
    end
  end

  class Snippet

    attr_reader :ident
    attr_accessor :path
    attr_accessor :env

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

    def exist?
      true
    end

  end

  class Env
    attr_reader :locals

    def initialize(locals)
      @locals = locals

      if Habitat.quart.plugins.activated?(:flickr)
        extend(Flickr)
      end
    end

    def active_path(path)
      path == locals[:request_path]
    end

    def active_path_li(path, desc)
      "<li class='%s'><a href='%s'>%s</a></li>" % [active_path(path) ? "active" : "", path, desc, desc]
    end
  end


  class NotExistingSnippet < Snippet
    def read
      ""
    end
    def render
      "<span class='not-existing-snippet'><code>#{ident}</code> not exist</span>"
    end

    def exist?
      false
    end
  end

  class MarkdownSnippet < Snippet
    def filename
      super("markdown")
    end

    def render
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true, footnotes: false)
      markdown.render
    end
  end

  class HAMLSnippet < Snippet
    def filename
      super("haml")
    end

    def render
      locals = {}
      if env
        locals[:request_path] = env.env['REQUEST_PATH']
      end
      "%s" % Haml::Engine.new(to_s).render(Env.new(locals), locals)
    end
  end

end
