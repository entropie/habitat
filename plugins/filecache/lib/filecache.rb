module FileCache
  DEFAULT_CACHE_TIMER = 60*60*24

  def self.cache_directory(*arg)
    Habitat.quart.media_path("cache", *arg)
  end

  def self.cache_directory=(obj)
    @cache_directory = obj
  end

  def self.cache_directory_exist?
    ::File.exist?(cache_directory)
  end

  def self.ident_to_file(ident)
    FileUtils.mkdir_p(FileCache.cache_directory) unless FileCache.cache_directory_exist?
    FileCache.cache_directory(ident.to_s + ".cache")
  end

  def self.cached_or_fresh(ident, force_when:, &blk)
    file = ident_to_file(ident)
    if !::File.exist?(file) || force_when.call(file)
      Habitat.log :info, "FC: #{ident}: caching (#{file}"
      worker = yield
      File.open(file, "w+"){ |fp| fp.puts(worker) }
      worker
    else
      Habitat.log :info, "FC: #{ident}: reading from cachefile (#{file})"
      File.readlines(file).join
    end
  end
end

