module Bagpipe

  class Entries < Array
    attr_reader :parent
    def initialize(parent)
      @parent = parent
    end

    def read(arg)
      @parent.read(arg)
    end

    def song?
      false
    end


    def recursive_each(&blk)
      parent.recursive_each(&blk)
    end
  end

  class Repository

    ValidSongExtensions =   ["mp3", "mp4", "ogg", "wav"].freeze
    ValidPackedExtensions = ["zip", "rar", "gz", "bz2"].freeze

    include Bagpipe

    module FFile
      def read
        ::File.read(@path)
      end
    end

    module Playable
    end

    module Downloadable
    end


    def read(arg = "/")
      tfile =  ::File.join(@path, arg)
      tclass = Entry.select_for(tfile)
      if tclass.directory?
        tclass.read
      else
        tclass
      end
    end

    module Browseable

      def entries(arg = nil)
        @entries ||= read(arg)
      end

      def recursive_each(&blk)
        self.entries.each do |entry|
          if entry.directory?
            entry.recursive_each(&blk)
          elsif entry.playable?
            yield entry
          end
        end
      end

      def read(arg = nil)
        target_path = "/"
        target_path = arg if arg

        target_fpath = ::File.join(@path, target_path)

        rentries = Dir.entries(target_fpath).reject{|entry| entry =~ /^\.+/ }
        ret = rentries.map{|dc| Entry.select_for( ::File.join(target_fpath, dc)) }

        sort_by_type_and_name!(ret)

        Entries.new( Entry.select_for(target_fpath) ).push(*ret)
      end

      def sort_by_type_and_name!(entries)
        dirs, songs, rest, packs = [], [], [], []
        entries.each do |entry|
          case entry
          when Song
            songs << entry
          when Directory
            dirs << entry
          when Packed
            packs << entry
          else
            rest << entry
          end
        end
        entries.replace(dirs.sort + songs.sort + packs.sort + rest.sort)
      end

      class Cnt
        def initialize(i = 0)
          @cnt = i
        end
        def succ
          @cnt+=1
        end
        def to_i
          @cnt
        end
      end


      def to_pls(env, j = Cnt.new, str = "[playlist]\n", init = true)
        each do |entry|
          if entry.song?
            str << "File#{j.succ}=#{entry.http_path(env)}\n"
            str << "Title#{j.to_i}=#{::File.basename(entry.path)}\n"
          elsif entry.directory?
            str << entry.read.parent.to_pls(env, j, '', false)
          end
        end
        
        if init
          str << "\nNumberOfEntries=#{j.to_i}\n"
          str << "Version=2"
        end
        str
      end

    end

    class Entry

      include Bagpipe

      attr_reader :path

      def inline_playable?
        false
      end

      def directory?
        false
      end

      def short_path
        subbed = path.to_s.sub(Habitat.adapter(:bagpipe).path, "")
        subbed[1..-1]
      end

      def basename
        ::File.basename(path)
      end

      def <=>(o)
        path <=> o.path
      end

      def initialize(spath)
        @path = spath
      end

      def basename
        ::File.basename(@path)
      end

      def directory?
        false
      end

      def song?
        false
      end

      def self.select_for(spath)
        ext = ::File.extname(spath)[1..-1].downcase rescue ""

        target =
          if ::File.directory?(spath)
            Directory
          elsif ValidSongExtensions.include?(ext)
            Song
          elsif ValidPackedExtensions.include?(ext)
            Packed
          else
            Other
          end

        target.new(spath)
      end

      def inspect
        %Q'<%-10s "#{path}" : "#{short_path}">'
      end

      def link(prfx = "/", icn = "")
        %Q'<a class="#{csscls}" href="#{prfx}%s">#{icn} #{File.basename(path)}</a>'
      end

      def parent
        Entry.select_for(::File.join("..", path))
      end

      def playable?
        true
      end
    end

    class Packed < Entry
      include Downloadable

      def playable?
        false
      end

      def inspect
        what = ::File.extname(path)[1..-1]
        super % "Pack(#{what})"
      end

      def csscls
        "pack"
      end

      def link(prfx = "")
        super(prfx) % ("raw/download/" + path.split("/").map{|part| Rack::Utils.escape(part)}.join("/"))
      end
 
      def image(width = 32, height = 32)
        %Q'<div class="pimg"><img src="/img/zip-d.png" height="#{height}" width="#{width}" /></div>'
      end
    end

    class Directory < Entry
      include Browseable

      def directory?
        true
      end

      def inspect
        super % "Directory"
      end

      def each(&blk)
        entries.each(&blk)
      end

      def csscls
        "dir#{top? ? " toplink" : ""}"
      end

      def top?
        short_path == ""
      end

      def link(prfx = "", icn = "")
        super(prfx, icn) % short_path
      end

      def play_link(prfx = "", icn = "")
        %Q'<a class="play-link #{csscls}" href="#{prfx}%s" target="player">#{icn}</a>' % short_path
      end

    end

    class Song < Entry
      include FFile
      include Playable

      def inline_playable?
        File.extname(path).downcase == ".mp3"
      end

      def song?
        true
      end

      def each
        yield self
      end

      def recursive_each
        yield self
      end

      def http_path(env)
        scheme = env["rack.url_scheme"]
        scheme = "https" if Habitat.quart.production?

        url = "%s://%s/" % [ scheme, env["HTTP_HOST"] ]

        suffix = "assets/bagpipe/" + short_path
        url+suffix
        
      end

      def inspect
        super % "Song"
      end

      def csscls
        "song"
      end

      def image(width = 20, height = 20)
        ""
      end

      def link(prfx = "", icn = "")
        super(prfx, icn) % ("play/" + short_path)
      end

      def play_link(prfx = "", icn = "")
        %Q'<a class="play-link #{csscls}" href="#{prfx}%s" target="player">#{icn}</a>' % short_path
      end

      def to_pls(env, j = 0, str = "[playlist]\n", init = true)
        str << "File#{j.succ}=#{http_path(env)}\n"
        str << "Title#{j.to_i}=#{::File.basename(path)}\n"
        str << "\nNumberOfEntries=#{j.to_i}\n"
        str << "Version=2"
        str
      end

    end

    module Base64Image
      def to_data_uri
        img = File.join(Bagpipe.path, path)
        type = File.extname(img)[1..-1].downcase

        case type
        when "jpg", "jpeg", "gif", "png", "bmp"
          imgbody = [File.read(img)]
          imgbody = imgbody.pack("m").gsub("\n", '')
          return "data:#{type};base64,#{imgbody}"
        else
          false
        end
      end

      def name_or_image
        duri = to_data_uri
        if duri
          %Q'<img class="dimg" src="#{duri}" />'
        else
          File.basename(path)
        end
      end
    end

    class Other < Entry

      include Base64Image

      def inspect
        super % "Other"
      end

      def csscls
        "other"
      end

      def image(width = 20, height = 20)
        %Q'<div class="pimg" style="display:none"><img src="/img/home-d.png" height=#{height} width=#{width}/></div>'
      end

      def playable?
        false
      end

      def link(prfx = "", icn = "")
        '<span class="%s">%s %s</span>' % [csscls, icn, basename]
      end

      def name
      end

      def read
      end
    end

    attr_reader :path

    def initialize(path)
      @path = path
    end
  end

end

