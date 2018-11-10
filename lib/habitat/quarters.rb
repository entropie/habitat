module Habitat::Quarters

  class Quarters < Array

    extend Habitat

    def self.read_dir(param_dir = nil)
      log :debug, "quarters reading: '#{Habitat.quarters_root}'"
      (Dir["%s/*/" % (param_dir || quarters_root)]).each do |quarter_dir|
        quarters << Quart.read(quarter_dir)
      end
      quarters
    end
    
    def initialize
    end

    def [](obj)
      select{|a| a == obj}.first
    end
  end

  def self.[](obj)
    Quarters.read_dir
    Habitat.quarters[obj.to_sym]
  end

  class Quart

    attr_reader :identifier, :path
    include Habitat
    extend Habitat

    def self.read(path)
      log :debug, "registering #{path}"
      new(path)
    end

    def env
      ENV["HANAMI_ENV"]
    end

    def secret=(obj)
      @secret = obj
    end

    def secret
      @secret
    end

    def banner
      "[[#{identifier}:#{env}]]"
    end

    def production?
      env == "production"
    end

    def development?
      env == "development"
    end

    def initialize(path)
      @path = path
    end

    def ==(obj)
      if obj.kind_of?(String) or obj.kind_of?(Symbol)
        identifier == obj.to_sym
      elsif obj.kind_of?(Quart)
        identifier == obj.identifier
      else
        false
      end
    end

    def identifier
      @identifier = File.basename(@path).to_sym
    end

    def app_root(*args)
      quarters_root(identifier.to_s, *args.map(&:to_s))
    end

    def media_path(*args)
      app_root("media", *args)
    end

    def plugins
      @plugins ||= begin
                     Plugins.for(self)
      end
    end

    def config
      @config ||= begin
                    Configuration.for(self)
      end
    end

    def load_enviroment!
      Dir.chdir(app_root) do
        Hanami.boot
      end
      Plugins.load_from_symbols(config.fetch(:plugins))
    end

    def load_application_files_for_plugins!
      Plugins.load_application_files_for_plugins!(config.fetch(:plugins))
    end

    def plugin_mapping
      @plugin_mapping ||= Plugins.to_classes(config.fetch(:plugins))
    end

    def prepare_assets_for_production
      Dir.chdir app_root do
        puts %x"node ./node_modules/.bin/webpack --colors"
      end
      require 'uglifier'
      target = app_root("public/build/app-min.js")
      src    = app_root("public/build/app.js")
      ret = Uglifier.new.compile(File.read(src))
      File.open(target, "w+"){|fp| fp.puts(ret)}
    rescue
      FileUtils.cp(src, target)
      log :warn, "*** UGLIFIER FAILED: #{$!}"
    end
  end

  class DummyQuart < Quart

    include Habitat::Mixins::FU
    
    def self.create(ident, opts = {})
      new(quarters_root(ident.to_s))
    end

    def hanami_init
      Dir.chdir(quarters_root) do
        system "hanami new #{identifier} --database=sqlite  --template=haml"
      end
    end

    def skel_file(file)
      root("skel", file)
    end

    def from_skel(file)
      directory = dirname(app_root(file))
      mkdir_p(directory) unless File.directory?(directory)
      cp(skel_file(file), app_root(file))
    end

    def action_from_skel(cntrler)
      ["apps/web/controllers/#{cntrler}.rb",
       "apps/web/views/#{cntrler}.rb",
       "apps/web/templates/#{cntrler}.html.haml"
      ].each{|c|
        from_skel(c)
      }
    end

    def patch_file(file, pattern, cnts)
      ret = []
      contents = File.readlines(app_root(file))
      contents.each do |line|
        if line =~ pattern
          ret << line.gsub(pattern, cnts)
        else
          ret << line
        end
      end
      overwrite(app_root(file), ret.join)
    end

    def hanami_generate(action)
      Dir.chdir(app_root) do
        log :info, "hanami-generate: #{action}"
        system("bundle exec hanami generate #{action}")
      end
    end

    def app_run(cmd)
      log :info, "running: '#{cmd}'"
      Dir.chdir(app_root){
        Bundler.with_clean_env do
          system(cmd)
        end
      }
    end

    def run_script(script)
      script = script.to_s
      Bundler.with_clean_env do
        system("ruby scripts/#{script}")
      end
    end
    
    def habit_inhabit
      from_skel("Gemfile")

      from_skel("config/initializers/warden.rb")
      from_skel("config/environment.rb")

      patch_file("config/environment.rb", /(%%%identifier%%%)/, identifier.to_s)

      from_skel("apps/web/application.rb")

      hanami_generate("action web app#index")
      from_skel("apps/web/config/routes.rb")


      from_skel("apps/web/templates/application.html.haml")
      from_skel("apps/web/assets/stylesheets/screen.css.sass")
      from_skel("apps/web/assets/javascripts/application.js")

      from_skel("src")
      from_skel("log")
      from_skel("webpack.config.js")
      from_skel("package.json")

      app_run "bundle install --quiet"
      # app_run "npm --silent install --quiet > /dev/null 2>&1"
      # app_run "bundle exec hanami assets precompile"
      # app_run "npm --silent run build"

      app_run("bundle exec cap install")
      from_skel("Capfile")
      from_skel("config/deploy.rb")


      %w(nginx.conf unicorn_init.sh unicorn.rb).each do |cfg|
        cfgfile = File.join("config", cfg)
        from_skel(cfgfile)
        patch_file(cfgfile, /(%%%identifier%%%)/, identifier.to_s)
      end

      from_skel(".gitignore")

      from_skel(".quartersettings.yaml")
      from_skel(".projectsettings.yaml")
      
      app_run "mkdir -p media/assets"
      app_run "npm install"

      #run_script("git_init.rb #{identifier}")
    end

    def create
      hanami_init
      habit_inhabit
      Quart.read(app_root)
    end
  end



end
