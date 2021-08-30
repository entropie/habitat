module PageMeta

  def self.default_meta=(obj)
    @default_meta = obj
  end

  def self.default_meta
    @default_meta || Default
  end

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
      pm = PageMeta.default_meta.new
      pm.request = obj
      pm
    end
  end


  class Meta

    Attrs = [:image, :description, :url, :title]

    attr_reader *Attrs
    attr_accessor :request
    
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

    def key(sym)
      "og:#{sym}"
    end

    def meta_str
      "<meta content='%s' property='%s' />"
    end

    def to_hash
      {  }
    end

  end

  class Default < Meta
    def initialize()
    end

    def to_meta(args)
      ret = []
      to_hash.each_pair do |v, k|
        ret << meta_str % [k,v]
      end
      ret << site_title(args.to_s)
      ret.join("\n")
    end

  end
  
  class FaceBook < Meta

    def to_meta(*args)
      ret = []
      to_hash.each_pair do |v, k|
        ret << meta_str % [k,v]
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
