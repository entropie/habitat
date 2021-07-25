# coding: utf-8
module Snippets

  DEFAULT_ADAPTER = :File


  module SnippetsViewMethods
    def Snip(arg, env = nil)
      Habitat.adapter(:snippets).select(arg, env || locals[:params])
    end

  end

  module SnippetsControllerMethods
    def snippet_page(arg, lparams = [], env = nil)
      Habitat.adapter(:snippets).page(arg, lparams, env)      
    end
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
    end
  end

  class Snippet

    attr_reader :ident
    attr_accessor :path
    attr_accessor :env
    attr_accessor :content

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
        if snippet_filename =~ /---/
          PageSnippet
        elsif snippet_filename =~ /\.haml$/
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

    def css_class
      self.class.to_s.split("::").last.downcase
    end
  end

  
  

  class Env
    attr_reader :locals

    def initialize(locals)
      @locals = locals

      if Habitat.quart.plugins.activated?(:flickr)
        extend(Flickr)
      end

      if Habitat.quart.plugins.activated?(:galleries)
        extend(Galleries::GalleriesAccessMethods)
      end
    end

    def active_path(path)
      rp = locals[:request_path]
      #p "%s - %s" % [rp, path]
      if rp.include?("/s/") and path.include?("/s/") and rp.include?(path)
        true
      elsif rp =~ /^#{path}/
        true
      else
        path == rp
      end
    rescue
      false
    end

    def routes
      Habitat.quart.default_application.routes
    end

    # FIXME:
    def Snip(arg)
      ret = Habitat.adapter(:snippets).snippets[arg.to_sym]
      ret = NotExistingSnippet.new(arg) unless ret
      ret
    end

    def P(*args)
      routes.page_path(*args)
    end

    # def accept_cookies?
    #   locals.accept_cookies
    # end

    def LINK(path, desc)
      "<a class='#{active_path(path) ? "active" : ""}' href='#{path}'>#{desc}</a>"
    end

    def active_path_li(path, desc)
      "<li class='#{(active_path(path) ? "active" : "")}'>#{LINK(path, desc)}</li>"
    end

    alias :al :active_path_li
  end


  class NotExistingSnippet < Snippet
    def read
      ""
    end

    def render(*args)
      "<span class='be-msg not-existing-snippet'>(Error:<strong>snippet</strong>: <code>#{ident}</code> not exist)</span>"
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
      r = markdown.render(to_s)
    end
  end

  class HAMLSnippet < Snippet
    def filename
      super("haml")
    end

    def render(lcs = {})
      locals = lcs
      if env
        locals[:request_path] = env.env['REQUEST_PATH']
      end
      ret = "%s" % Haml::Engine.new(to_s).render(Env.new(locals.merge(lcs)), locals)
      ret
    # rescue
    #   "nope: something went wrong while processing #{ident}"
    end
  end

  class PageSnippet < HAMLSnippet
    def filename
      super
    end

    def parent?
      ident.to_s.split("---").size == 2
    end

    def children
      if parent?
        @children ||= Habitat.adapter(:snippets).grep("#{ident}---")
      end
    end
  end

end


