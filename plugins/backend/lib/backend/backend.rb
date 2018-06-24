module Backend

  def self.q
    Habitat.quart
  end
  
  def self.backend_modules
    q.plugins.select {|plug| plug.backend? }.map do |plug|
      plug.identifier
    end
  end
  
end
