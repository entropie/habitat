module Habitat

  module Plugins

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
        log :debug, "loading plugins from #{quarter.identifier} config"

        quarter.config.fetch(:plugins).each do |plugincls_from_config|
          full_path = plugin_path(plugincls_from_config)
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
    end

    class PluginRepositoryAvailable < PluginRepository
      def read
        log :debug, "loading available plugins"
        Dir.glob("%s/*/" % plugin_path).each do |full_path|
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
