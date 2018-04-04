module Blog


  class Post

    Attributes = {
      :content     => String,
      :title       => String,
      :image       => String,
      :created_at  => Time,
      :updated_at  => Time,
      :user_id     => Fixnum,
      :tags        => Array
    }

    OptionalAttributes = [:image]
    
    attr_reader *Attributes.keys

    attr_accessor :filename, :datadir, :user_id
 
    def initialize(adapter)
      @adapter = adapter
    end

    def populate(param_hash)
      param_hash.each do |paramkey, paramval|
        instance_variable_set("@#{paramkey}", paramval)
      end
      self
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

    def datadir
      @datadir || @adapter.datadir(slug)
    end

    def for_yaml
      ret = dup
      ret.remove_instance_variable("@adapter")
      ret
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
