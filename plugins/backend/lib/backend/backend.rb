module Backend

  def self.q
    Habitat.quart
  end
  
  def self.backend_modules
    q.plugins.select {|plug| plug.backend? }.map do |plug|
      plug.identifier
    end
  end

  def self.submenu_template(bm)
    a = q.plugins.select {|plug| plug.backend? }.select{|plug|
      plug.identifier == bm
    }.first
    if tmplf = a.submenu_template(bm.to_s)
      return "%s/%s" % [bm.to_s, tmplf]
    end
    false
  end

 
end
