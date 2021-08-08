module PageMeta

  def self.for(obj)
    params = obj.params
    request_path = params.env["REQUEST_PATH"]

    if obj.respond_to?(:post) and current_post = obj.post
      imgurl = current_post.image ? current_post.image.url : ""
      fbm =
        FaceBook.new(:image => imgurl,
                     :description => current_post.intro,
                     :url => request_path,
                     :title => current_post.title)

      fbm
    else
      Default.new
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

    def site_title(title = "")
      title = "#{title} &mdash; " if title.size > 1
      "<title>%s%s</title>" % [title, C[:title]]
    end

  end

  class Default < Meta
    def initialize()
    end

    def to_meta(args)
      site_title(args.to_s)
    end
  end
  
  class FaceBook < Meta

    def key(sym)
      "og:#{sym}"
    end

    def to_meta(*args)
      str = "<meta content='%s' property='%s' />"
      ret = []
      to_hash.each_pair do |v, k|
        ret << str % [k,v]
      end
      ret << site_title(title)
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
