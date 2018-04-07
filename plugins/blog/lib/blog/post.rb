module Blog

  class Post

   Attributes = {
      :content     => String,
      :title       => String,
      :created_at  => Time,
      :updated_at  => Time,
      :tags        => Array,
      :image       => Image
    }

    OptionalAttributes = [:image]
    
    attr_reader :image, *Attributes.keys

    attr_accessor :filename, :datadir, :user_id, :created_at, :updated_at
 
    def initialize(adapter)
      @adapter = adapter
    end

    def populate(param_hash)

      if img = param_hash[:image]
        param_hash[:image] = Image.new(img.path)
      end

      if param_hash[:tags]
        param_hash[:tags] = param_hash[:tags].split(",").map{|t| t.to_s.strip }
      end

      param_hash.each do |paramkey, paramval|
        instance_variable_set("@#{paramkey}", paramval)
      end

      self
    end

    def upload(obj)
      obj.copy_to(self)
    end
    
    def to_hash
      Attributes.keys.inject({}) {|m, v|
        m[v] = instance_variable_get("@#{v}")
        m
      }
    end

    def slug
      @slug ||= title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end

    def id
      slug
    end

    def dirname
      "posts"
    end

    def to_filename
      "#{slug}#{Blog::Database::Adapter::File::BLOGPOST_EXTENSION}"
    end

    def filename
      @filename || @adapter.repository_path(dirname, to_filename)
    end

    def datadir(*args)
      @datadir || @adapter.datadir(slug, *args)
    end

    def for_yaml
      ret = dup
      ret.remove_instance_variable("@adapter")
      ret
    end

    def url
      slug
    end

    def draft?
      false
    end

    def valid?
      missing = []
      Attributes.each do |attribute, attribute_type|
        next if OptionalAttributes.include?(attribute)
        if not var = instance_variable_get("@#{attribute}")
          missing << attribute
        elsif not var.kind_of?(attribute_type)
          missing << attribute
        else # pass
        end
      end
      not missing.any?
    end

    def to_draft(adapter)
      Draft.new(adapter).populate(to_hash)
    end

  end

  class Draft < Post

    def initialize(adapter)
      super(adapter)
      @updated_at = @created_at = Time.now
    end
    
    def dirname
      "drafts"
    end

    def to_post(adapter)
      Post.new(adapter).populate(to_hash)
    end

    def draft?
      true
    end
  end


  class Posts < Array

    attr_reader :user

    def initialize(usr = nil)
      @user = usr
    end

  end

  class Groups < Hash
  end

  class Group < Posts
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def name_sanitized
      @name
    end

    def size(logged_in = false)
      posts(logged_in).size
    end
  end

end
