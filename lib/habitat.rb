require "rubygems"
require "bundler"

Bundler.require

require "pp"

module Habitat
  Version = [0, 0, 1]


  Source = File.dirname(File.dirname(File.expand_path(__FILE__)))

  def Source.join(*fragments)
    File.join(Source, *fragments)
  end

  $: << Source.join("lib/habitat")
  
  %w"mixins adapter supervisor quarters plugins configuration".each do |lib_to_load|
    require lib_to_load
  end
  
  def self.quart=(obj)
    @quart = obj
  end

  def self.quart
    @quart
  end

  def self.S(path)
    path.sub(root, "")
  end

  def self.Q
    Quarters.quart
  end

  def self.inhabit(ident)
    Quarters::Quarters.read_dir
    Habitat.quart = quarters(ident)
  end
  

  def self.quarters(arg = nil)
    @quarters ||= Quarters::Quarters.new
    return @quarters[arg] if arg
    @quarters
  end

  def self.adapter(arg = nil)
    @adapter ||= Habitat::Adapter.new
    return @adapter[arg] if arg
    @adapter
  end

  def self.add_adapter(symp, adapter)
    log :info, "registering adapter: #{adapter}"
    self.adapter[symp] = adapter
    self.adapter
  end

  def quarters_root(*args)
    root("quarters", *args)
  end
  module_function :quarters_root


  def quarters(arg = nil)
    Habitat.quart = Habitat.quarters(arg)
  end


  def root(*args)
    Source.join(*args.map(&:to_s))
  end
  module_function :root

  def plugin_path(*args)
    root("plugins", *args.map(&:to_s))
  end
  module_function :plugin_path

  def self._require(file)
    log(:debug, "::::require #{Habitat.S(file)}")
    require file
  rescue LoadError
    p $!
    p "!!!%s" % file
  end

  def log(k, msg, &blk)
    if Hanami::Components.resolved('logger')
      Hanami.logger.send(:info, "#{k}: #{msg}")
    else
      puts "%12s  %s" % [k.to_s, msg]
    end
  end
  module_function :log


  def self.load_application_files_for_plugins!
    Habitat.quart.load_application_files_for_plugins!
  end

  def self.mounts
    @mounts ||= {}
  end

  def self.default_application_config
    proc{
      middleware.use Rack::Session::Cookie, secret: "asd"
      middleware.use Warden::Manager do |manager|
        # let Hanami deal with the 401s
        #manager.intercept_401 = false
      end
      controller.prepare do
        include Habitat
        include Habitat::WebAppMethods
      end
      view.prepare do
        include Habitat
        include Habitat::WebAppMethods
      end
    }
  end


  module WebAppMethods

    def logged_in?
      !!params.env['warden'].user
    end

    def session_user
      params.env['warden'].user
    end

    def _javascript(str)
      src = if Habitat.quart.production?
              File.join("/build/", str + "-min")
            else
              File.join("/build", str)
            end
      src += ".js"
      raw("<script src='#{src}' defer></script>")
    end

    def al(href, text = nil, opts = {})
      text = href unless text
      path = locals[:params].env["REQUEST_PATH"]

      add_content = ""

      if icon = opts[:icon]
        add_content << "<span class='glyphicon glyphicon-#{icon}'></span>"
      end
      clz = path == href ? "active" : ""

      ret = "<a href='%s' class='%s'>%s</a>" % [href, "#{clz} #{opts[:class] || "alink"}", text + add_content]
      _raw(ret)
    end
    def adapter(ident)
      ident = ident.to_sym
      Habitat.adapter(ident)
    end

    def adapter_with_usercontext(adapterident, usr = nil, &blk)
      user = usr || session_user
      if user
        adapter(adapterident).with_user(user, &blk)
      end
    end
  end


  include Mixins
end


Haml::Options.defaults[:format] = :html5
# # Haml::Options.defaults[:remove_whitespace] = true
class Hanami::View::Template
  def initialize(t, e = Encoding::UTF_8)
    a = Tilt.new(t, nil, default_encoding: e, remove_whitespace: false)
    @_template = a
  end
end



