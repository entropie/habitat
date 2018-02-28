require "yaml"

module Habitat

  module Configuration

    def self.for(quarter)
      Config.new(quarter)
    end

    class Config

      include Habitat::Mixins::FU

      class ConfigHash < Hash
        def initialize
          #super{|h,k| h[k] = ConfigHash.new}
        end
      end

      Defaults = {
        plugins: []
      }

      ConfigFile = ".quartersettings.yaml"
      
      def initialize(quarter)
        @quarter = quarter
        @config  = ConfigHash.new
        read
      end


      def fetch(obj)
        @config[obj.to_sym]
      end

      def update!(&blk)
        yield @config
        write
      end

      def file
        @file ||= @quarter.app_root(ConfigFile)
      end


      private

      def set_defaults
        @config.merge!(Defaults)
        @config
      end
      
      def config_file_exist?
        File.exist?(file)
      end

      def write
        super(file, @config.to_yaml)
      end
      
      def read
        unless config_file_exist?
          set_defaults
          write
        else
          log :info, "reading config #{file}"
          @config = YAML::load_file(file)
        end
      end
    end

  end
  
end
