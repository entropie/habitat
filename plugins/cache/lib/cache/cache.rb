$cache = Memcached.new("localhost:11211")

module Cache
  def self.cache_key(k)
    "%s-%s" % [Habitat.quart.identifier, k]
  end

  def self.[](obj)
    ret = $cache.get(cache_key(obj)) rescue nil
    Habitat.log :debug, "get Cache(%s, '%s')" % [ obj, ret]
    ret
  end

  def self.[]=(obj, value)
    Habitat.log :debug, "set Cache(%s, '%s')" % [ obj, value]
    $cache.set(cache_key(obj), value)
  end

end

