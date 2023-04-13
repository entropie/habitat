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
          next if h.kind_of?(DefaultHandler)
          h.responsible_for?(post)
        }

        raise "multiple handler for #{post} found; cannot continue" if ret.size > 1

        handler = ret.first
        handler = DefaultHandler unless handler

        Habitat.log(:debug, "tumblog: (#{handler}:'#{post.content}')")

        handled = handler.new(post)
        handled
      end

      def self.responsible_for?(post)
        r = match.any?{|r| post.content =~ r}
      end
      
      def initialize(post)
        @post = post
      end

      def process!
      end

      def download(url, target)
        ret = nil
        Habitat.log :debug, "DL: #{url} -> #{target}"
        open(url){|v|
          File.open(target, "wb") {|fp|
            ret = fp.write(v.read)
            Habitat.log :debug, "DL: wrote #{ret}"
          }
        }
        ret
      end

      def thumbnail?
        File.exist?(thumbnail_file)
      end

      def thumbnail_file
        post.datadir("thumbnail.jpg")
      end

      def thumbnail_src
        post.http_data_dir("thumbnail.jpg")
      end

      def title
        if post.title and not post.title.to_s.strip.empty?
          post.title
        else
          "&nbsp;"
        end
      end

      def to_html(logged_in = false)
        b = "%s"
        add = ""
        if thumbnail?
          add << %Q|<img class='preview' src='#{thumbnail_src}''/>|
        end
        ret = "#{add}<video controls style='display:#{thumbnail? ? "none" : "inline-block"}'><source src='%s' type='video/mp4'></video>"
        b % ret
      end

      def self.match
        [false]
      end

      def process!
        true
      end

      def create_interactive?
        false
      end
      

      module YoutubeDLMixin
        def media_file
          Dir.glob("%s/%s.*" % [post.real_datadir, post.id]).first          
        end

        def media_file_src
          post.http_data_dir(File.basename(media_file))
        end
      end

      class DefaultHandler < Handler

        def create_interactive?
          true
        end
        
        def to_html(logged_in = false)
          markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
          markdown.render(post.content)
        end

      end

      class Reddit < Handler

        include YoutubeDLMixin
        include Habitat::Mixins::FU
        
        def thumbnail_file
          post.real_datadir("#{post.id}.jpg")
        end

        def thumbnail_src
          post.http_data_dir("#{post.id}.jpg")
        end


        def self.match
          [/^https:\/\/reddit\.com/, /^https:\/\/www\.reddit\.com/, /^https:\/\/v\.redd\.it\//]
        end

        def process!
          FileUtils.mkdir_p(post.datadir)

          target_file = post.datadir(post.id + ".mp4")
          if ::File.exist?(target_file)
            rm(target_file)
          end

          log :info, "ytdl: #{post.id} #{post.content} #{target_file}"

          ydl = YoutubeDL.download(post.content, output: target_file, write_thumbnail: true)
          post.title = ydl.information[:title]
          true
        end

        def to_html(logged_in = false)
          ret = super % post.http_data_dir(post.id + ".mp4")
          ret + "<div class='source'>#{post.content}</div>" 
        end
      end

      class Youtube < Handler
        include YoutubeDLMixin

        def self.match
          [/^https:\/\/youtube\.com/, /^https:\/\/www\.youtube\.com/]
        end

        def process!
          FileUtils.mkdir_p(post.datadir)

          target_file = post.datadir(post.id)
          ydl = YoutubeDL.download(post.content, output: target_file)
          post.title = ydl.information[:title]
          true
        end

        def to_html(logged_in = false)
          add = "<h3>#{post.title}</h3>"
          ret = "%s<video controls><source src='%s' type='video/mp4'></video>"
          ret % [add, media_file_src]
        end
      end

      class GFYcat < Handler
        include YoutubeDLMixin

        def self.match
          [/gfycat\.com/]
        end


        def process!
          FileUtils.mkdir_p(post.datadir)

          target_file = post.datadir(post.id)
          ydl = YoutubeDL.download(post.content, output: target_file)
          post.title = ""
          true
        end


        def to_html(logged_in = false)
          # %Q|<img class='preview' src='%s'/>| % post.http_data_dir("#{post.id}")
          add = "<h3>#{post.title}</h3>"
          ret = "%s<video controls><source src='%s' type='video/mp4'></video>"
          ret % [add, post.http_data_dir("#{post.id}")]
        end

      end

      class Img < Handler
        def self.match
          [/\.gifv$/i]
        end

        def process!
          FileUtils.mkdir_p(post.datadir)

          target_file = post.datadir(post.id + ".mp4")

          srcurl, thumbnail = "", ""
          open(post.content) do |uri|
            html = Nokogiri::HTML(uri.read)
            srcurl = html.xpath('//meta[@itemprop="contentURL"]').first[:content]
            thumbnail = html.xpath('//meta[@itemprop="thumbnailUrl"]').first[:content]
          end
          ret = download(srcurl, target_file)
          download(thumbnail, thumbnail_file)
          ret
        end


        def to_html(logged_in = false)
          super % post.http_data_dir(post.id + ".mp4")
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
      :user_id     => Integer,
      :private     => Integer
    }

    attr_reader *Attributes.keys
    attr_accessor :user_id, :datadir, :filename, :title, :private

    def initialize(a)
      @adapter = a
      @private = 0
    end

    def populate(param_hash)
      param_hash.each do |paramkey, paramval|
        if paramval.class != Attributes[paramkey]
          Habitat.log :error, "wrong type;expected:#{Attributes[paramkey]}: #{paramkey}:'#{paramval}'"
        end
        instance_variable_set("@#{paramkey}", paramval)
      end
      @tags = [] unless @tags
      @updated_at = @created_at = Time.now
      @id = Habitat::Database.get_random_id
      self
    end

    def update(hash)
      changed = false

      if new_tags = hash[:tags]
        @tags = Tumblog.tagify(new_tags)
      end

      if new_title = hash[:title]
        @title = new_title
      end

      new_content = hash[:content]

      if new_content && new_content != self.content and 
        changed = true
        @content = hash[:content]
      end

      changed
    end

    def to_hash
      Attributes.keys.inject({}) {|m, k|
        m[k] = instance_variable_get("@%s" % k.to_s)
        m
      }
    end

    def private?
      @private == 1
    end

    def private!
      @private = 1
    end

    def titled?
      @title && @title.to_s.strip.size > 1
    end

    def to_yaml
      r = self.dup
      r.remove_instance_variable("@adapter") if @adapter
      r.remove_instance_variable("@handler") if @handler
      YAML::dump(r)
    end

    def http_data_dir(*args)
      File.join("/attachments", id, *args)
    end


    def datadir(*args)
      adapter.datadir(id, *args)
    end

    def real_datadir(*args)
      adapter.datadir(id, *args)
    end

    def relative_datadir(*args)
      ::File.join("../data", id, *args)
    end

    def to_filename
      "#{id}#{Tumblog::Database::Adapter::File::BLOGPOST_EXTENSION}"
    end

    def filename
      @filename || ::File.join(dirname, to_filename)
    end

    def adapter
      @adapter ||= Habitat.adapter(:tumblog)
    end

    def relative_filename
      filename
    end

    def exist?
      true
    end

    def dirname
      "tumblblog/entries/#{@created_at.strftime("%Y%m")}"
    end

    def handler
      @handler ||= Handler.select_for(self)
    end

    def to_html(logged_in = false)
      handler.to_html(logged_in)
    end

    def css_class
      visible_add = @private == 1 ? " private" : ""
      "tumblog-entry#{visible_add}"
    end

    def css_id
      "entry-#{id[0..10]}"
    end

    def slug
      @slug || id
    end

    def kind
      handler.class.to_s.downcase.split("::").last.to_sym
    end

  end

  class Entries < Array
    attr_reader :user
    def initialize(user)
      @user = user
    end
  end
  
end
