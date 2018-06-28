module Tumblog

  class Post

    Attributes = {
      :content     => String,
      :title       => String,
      :created_at  => Time,
      :id          => String,
      :updated_at  => Time,
      :tags        => Array,
      :user_id     => Fixnum
    }

    OptionalAttributes = [:image, :title, :tags]

    attr_reader *Attributes.keys
    attr_accessor :user_id, :datadir, :filename

    def initialize(a)
      @adapter = a
    end

    def populate(param_hash)
      param_hash.each do |paramkey, paramval|
        instance_variable_set("@#{paramkey}", paramval)
      end
      @updated_at = @created_at = Time.now
      @id = Habitat::Database.get_random_id
      self
    end

    def to_hash
      Attributes.keys.inject({}) {|m, k|
        m[k] = instance_variable_get("@%s" % k.to_s)
        m
      }
    end

    def to_yaml
      r = self.dup
      r.remove_instance_variable("@adapter")
      YAML::dump(r)
    end

    def http_data_dir(*args)
      File.join("/attachments", id, *args)
    end


    def datadir(*args)
      if @datadir
        File.join(@datadir, *args)
      else
        @adapter.datadir(id, *args)
      end
    end

    def to_filename
      "#{id}#{Tumblog::Database::Adapter::File::BLOGPOST_EXTENSION}"
    end

    def filename
      @filename || @adapter.repository_path(dirname, to_filename)
    end

    def dirname
      "entries/#{@created_at.strftime("%Y%m")}"
    end

    def to_html
      title = "<h3>#{title}</h3>"
      ret = "%s<video controls><source src='%s' type='video/mp4'></video>"
      #File.exist?(datadir(id + ".mp4"))
      ret % [title, http_data_dir(id + ".mp4")]
    end

  end

  class Entries < Array
    attr_reader :user
    def initialize(user)
      @user = user
    end
  end
  
end
