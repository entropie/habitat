require "open-uri"

module Tumblog

  class Post

    class Handler

      attr_reader :post

      def self.handler
        @@handler ||= []
      end

      def self.inherited(o)
        handler << o
      end

      def self.select_for(post)
        ret = handler.select{|h|
          h.responsible_for?(post)
        }
        handler = ret.first.new(post)
        handler
      end

      def self.responsible_for?(post)
        r = match.any?{|r| post.content =~ r}
      end
      
      def initialize(post)
        @post = post
      end

      def process!
      end
      
      class YoutubeDLer < Handler
        def self.match
          [/reddit\.com/,
           /youtube.com/
          ]
        end

        def process!
          FileUtils.mkdir_p(post.datadir)

          target_file = post.datadir(post.id + ".mp4")
          ydl = YoutubeDL.download(post.content, output: target_file)
          post.title = ydl.information[:title]
          true
        end

        def to_html
          add = "<h3>#{post.title}</h3>"
          ret = "%s<video controls><source src='%s' type='video/mp4'></video>"
          ret % [add, post.http_data_dir(post.id + ".mp4")]
        end
      end

      class Img < Handler
        def self.match
          [/\.gif$/i, /\.gifv$/i]
        end

        def process!
          FileUtils.mkdir_p(post.datadir)

          target_file = post.datadir(post.id + ".mp4")

          srcurl = ""
          open(post.content) do |uri|
            html = Nokogiri::HTML(uri.read)
            srcurl = html.xpath('//meta[@itemprop="contentURL"]').first[:content]
          end
          ret = nil
          open(srcurl){|v|
            File.open(target_file, "wb") {|fp|
              ret = fp.write(v.read)
            }
          }
          ret
        end


        def to_html
          add = "<h3>#{post.title}</h3>"
          ret = "%s<video controls><source src='%s' type='video/mp4'></video>"
          ret % [add, post.http_data_dir(post.id + ".mp4")]
        end
        
      end
    end


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
    attr_accessor :user_id, :datadir, :filename, :title

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
      r.remove_instance_variable("@handler")
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

    def handler
      @handler = Handler.select_for(self)
    end

    def to_html
      handler.to_html
    end

  end

  class Entries < Array
    attr_reader :user
    def initialize(user)
      @user = user
    end
  end
  
end
