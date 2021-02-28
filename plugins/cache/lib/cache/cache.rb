#$cache = Memcached.new("localhost:11211")

module Cache

  def self.cache
    @cache ||= Memcached.new("localhost:11211")
  end
  
  def self.cache_key(k)
    "%s-%s" % [Habitat.quart.identifier, k]
  end

  def self.[](obj)
    ret = cache.get(cache_key(obj)) rescue nil
    Habitat.log :debug, "get Cache(%s, '%s')" % [ cache_key(obj), ret]
    ret
  end

  def self.[]=(obj, value)
    Habitat.log :debug, "set Cache(%s, '%s')" % [ cache_key(obj), value]
    cache.set(cache_key(obj), value)
    value
  end

end

