module PageMeta

  def self.for(obj)
    params = obj.params
    request_path = params.env["REQUEST_PATH"]

    pp params.env
    if current_post = obj.post
      pp FaceBook.new(:image => current_post.image.url, :description => current_post.intro, :url => request_path, :title => current_post.title).to_hash
    end
  end


  class Meta
    Attrs = [:image, :description, :url, :title]
    attr_reader *Attrs
    
    def initialize(hsh)
      Attrs.each do |attr|
        instance_variable_set("@#{attr}", hsh.delete(attr))
      end
      pp self
    end
  end

  class FaceBook < Meta

    def key(sym)
      "og:#{sym}"
    end

    def to_hash
      {
        key(:content)     => title,
        key(:type)        => "article",
        key(:url)         => url,
        key(:site_name)   => "fluffology",
        key(:image)       => image,
        key(:description) => description
      }
    end
  end

end
