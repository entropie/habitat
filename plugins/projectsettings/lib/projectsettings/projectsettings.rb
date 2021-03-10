module ProjectSettings

  class Settings < Hash

    include Habitat::Mixins::FU

    SETTINGSFILE = ".projectsettings.yaml".freeze
    
    def self.cache_key(str)
      "C-%s" % str.to_s
    end

    def initialize
      if Habitat.quart
        read
      end
    end

    def []=(obj, val)
      merge!(obj => val)
    end

    def read
      Habitat.log :info, "reading projectsettings"
      merge! YAML::load_file(Habitat.quart.app_root(SETTINGSFILE))
      # Habitat.plugin_enabled?(:cache) do
      #   each_pair do |k, v|
      #     Cache[Settings.cache_key(k)] = v
      #   end
      # end
    end
    
    def write(target = nil)
      target = File.join(target || Habitat.quart.app_root, SETTINGSFILE)
      super(target, YAML::dump(self))
    end

    def delete(obj)
      obj = obj.to_sym
      Habitat.log :info, "removing '#{obj}' from config"
      super(obj)
      write
    end
  end

  def self.to_s
    settings.to_s
  end

  def self.settings
    @settings ||= Settings.new
  end

  def self.[](obj)
    # Habitat.plugin_enabled?(:cache) do
    #   cached_settings = Cache[Settings.cache_key(obj)]
    #   if cached_settings
    #     return cached_settings
    #   end
    # end
    settings[obj]
  end

  def self.[]=(obj, val)
    settings[obj.to_sym] = val
  end

  def self.delete(obj)
    settings.delete(obj.to_sym)
  end

  def self.write(target = nil)
    settings.write(target)
  end
end



C = ProjectSettings

LOADED_SETTINGS = C.settings
