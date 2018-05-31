p 24

module PageMeta

  def self.for(obj)
    params = obj.params
    request_path = params.env["REQUEST_PATH"]

    if current_post = obj.post
      fbm =
        FaceBook.new(:image => current_post.image.url,
                     :description => current_post.intro,
                     :url => request_path,
                     :title => current_post.title)

      fbm.to_meta
    end
  end


  class Meta
    Attrs = [:image, :description, :url, :title]
    attr_reader *Attrs
    
    def initialize(hsh)
      Attrs.each do |attr|
        instance_variable_set("@#{attr}", hsh.delete(attr))
      end
    end

    def furl(str)
      File.join(::ProjectSettings[:host], str)
    end

  end

  class FaceBook < Meta

    def key(sym)
      "og:#{sym}"
    end

    def to_meta
      str = "<meta content='%s' property='%s' />"
      ret = []
      to_hash.each_pair do |k, v|
        ret << str % [k,v]
      end
      ret.join("\n")
    end


    def to_hash
      {
        key(:content)     => title,
        key(:type)        => "article",
        key(:url)         => furl(url),
        key(:site_name)   => "fluffology",
        key(:image)       => furl(image),
        key(:description) => description
      }
    end
  end

end
