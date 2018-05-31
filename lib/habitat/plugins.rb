module Habitat

  module Plugins

    def self.load_from_symbols(symbol_array)
      Habitat.log :debug, "require plugins from config"
      symbol_array.each do |sa|
        plugin_file = Habitat.plugin_path(sa, "lib", "#{sa}.rb")
        Habitat._require plugin_file
      end
    end
    
    def self.to_classes(symbol_array)
      symbol_array.inject({}){|m, sa|
        k = sa.to_s.capitalize
        ret = Object.const_get(k)
        m[sa] = ret
        m
      }
    end

    def self.load_application_files_for_plugins!(symbol_array)
      symbol_array.each do |plugin_symbol|
        application_file = Habitat.plugin_path(plugin_symbol, "application.rb")
        Habitat._require application_file
        Habitat._require Habitat.plugin_path(plugin_symbol, "lib", plugin_symbol, plugin_symbol)
      end

    end
    
    def self.for(quarter)
      pr = PluginRepository.new(quarter)
      pr.read
    end

    class PluginRepository < Array

      attr_reader :quarter

      def self.available(quarter)
        @available ||= PluginRepositoryAvailable.new(quarter).read
      end

      def initialize(quarter)
        @quarter = quarter
      end

      def read
        Habitat.log :debug, "loading plugins (#{PP.pp(quarter.config.fetch(:plugins), "").strip})"
        quarter.config.fetch(:plugins).each do |plugincls_from_config|
          full_path = Habitat.plugin_path(plugincls_from_config)
          plugin = Plugin.new(quarter, full_path)
          push(plugin)
        end
        self
      end

      def available
        PluginRepository.available(quarter)
      end

      def to_s
        map{|plug|
          plug.identifier
        }.join(", ")
      end

      def [](obj)
        i = obj.to_sym
        r = select{|p| p.identifier == i}
        if r.empty?
          raise "no valid plugin: #{obj}"
        end
        r.first
      end

      def activated?(symorstr)
        sym = symorstr.to_sym
        select{|p| p.identifier == sym }.any?
      end

      def name
        self.class.to_s.split("::").last
      end
      
      def push(obj)
        Habitat.log :debug, "#{self.name} << #{obj.identifier}"
        super
      end
    end

    class PluginRepositoryAvailable < PluginRepository
      def read
        Habitat.log :debug, "loading available plugins"
        Dir.glob("%s/*/" % Habitat.plugin_path).each do |full_path|
          plugin = Plugin.new(quarter, full_path)
          push(plugin) unless quarter.plugins.include?(plugin)
        end
        self
      end

    end

    class Plugin
      attr_reader :quarter, :path

      def activate
        quarter.plugins.push(self)
        quarter.plugins.available.delete_if{|plug| plug.identifier == identifier}

        quarter.config.update! do |cfg|
          cfg[:plugins].push(identifier)
        end
      end

      def deactivate
        quarter.plugins.available.push(self)
        quarter.config.update! do |cfg|
          cfg[:plugins].delete_if{|ident| ident == identifier}
        end
      end

      def initialize(quarter, full_path)
        @path = full_path
        @quarter = quarter
      end

      def identifier
        @identifier || File.basename(path).to_sym
      end

      def root(*args)
        File.join(@path, *args)
      end

    end
  end
  
end
