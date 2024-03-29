# coding: utf-8
module Booking

  def self.date_identifier(date)
    date.strftime("%y-%m-%d")
  end
  
  class Events < Array

    class EventTypes
      def self.types
        @types ||= []
      end

      def self.frontend_types
        types.reject{ |et| et.new.is_parent? }
      end
    end


    class DateRange
      attr_reader :begin_date, :end_date
      def initialize(begind, endd)
        @begin_date = if begind.kind_of?(Time) or begind.kind_of?(Date) then begind else Time.parse(begind) end
        @end_date   = if endd.kind_of?(Time) or endd.kind_of?(Date)     then endd   else Time.parse(endd)   end
      end

      def begin_date_p
        begin_date.form_date
      end

      alias :start_date :begin_date

      def end_date_p
        end_date.form_date
      end

      def date_identifier
        Booking.date_identifier(begin_date)
      end

      def to_human_time
        begin_date.to_human_time
      end

      def only_human_date
        begin_date.only_human_date
      end

      def only_human_time
        begin_date.only_human_time
      end

      def duration
        (@end_date.to_i - @begin_date.to_i).abs
      end

      def duration_text
        duration_in_h = duration / 60 / 60
        if duration_in_h > 24
          days = duration / 60 / 60 / 24
          if days > 1
            return "%s Tage" % days
          else
            return "1 Tag"
          end
        end
        if duration_in_h > 1
          return "%s Stunden" % duration_in_h
        else
          return "1 Stunde"
        end
      end

      def is_past?(odate = Time.now)
        begin_date < odate
      end
    end

    class Event

      EventAttributes = [
        :title,
        :slug,
        :dates,
        :protagonists,
        :attender_slots,
        :price
      ]

      DataAttributes = [
        :content
      ]

      attr_accessor *EventAttributes
      attr_accessor *DataAttributes

      attr_accessor :published

      attr_accessor :updated_at, :created_at

      attr_accessor :selected_date

      def self.normalize_params(paramhash)
        ret = {  }
        nh = paramhash.to_hash
        nh.each_pair{ |k,v|
          ret[k.to_sym] = v
        }
        ret
      end

      def self.inherited(o)
        Events::EventTypes.types << o
        Habitat.log :info, "adding #{o} to EventTypes"
      end

      def self.find_for_type(type)
        symtype = type.to_sym
        retclz = EventTypes.types.select{ |et| et.type == symtype }.shift
        retclz || Event
      end

      def self.create(paramhash)
        created_event = Event
        normalized_params = Event.normalize_params(paramhash)
        type = normalized_params[:type]
        normalized_params[:ident] = ::Habitat::Database::make_slug(normalized_params[:ident])
        if existing = Habitat.adapter(:booking).events.by_slug(normalized_params[:ident])
          raise "exists: #{existing.slug}"
        end

        if type
          created_event = find_for_type(type)
        end

        ev = created_event.new
        ev.set(normalized_params)
        ev
      end

      def self.exist?(slug)
        Habitat.adapter(:booking).events.by_slug(slug)
      end

      def initialize
        @created_at = Time.now
        @published = false
      end

      def ident_suggestion
        default_str = "%s--%s-kalenderwoche-%s"
        is = begin 
               Booking::Events::EventTypes.frontend_types.first.type.to_s.downcase
             rescue
               human_type.downcase
             end
        args = [is, Habitat::Database.get_random_id(6), start_date.strftime("%U"), start_date.strftime("%y")]
        default_str % args
      end

      def =~(obj)
        type == obj.to_sym
      end

      def attend(att_hash, slot = nil, &blk)
        attn = Attender.new(slug, att_hash, slot)
        @attender = nil
        Habitat::Mixins::FU.write(attn.filename, YAML::dump(attn))
        yield attn if block_given?
        attn
      end

      def attender
        @attender ||= Attender.load_for(self)
      end

      def attender_path(*args)
        Habitat.adapter(:booking).repository_path("eventattender", slug, *args)
      end

      def ident
        slug
      end

      def ident=(o)
        @slug = o
      end

      # dont need to sed type
      def type=(o)
      end

      def publish!
        @published = true
      end

      def unpublish!
        @published = false
      end

      def published?
        @published
      end

      def archived?
        @archived || false
      end

      def archived=(obj)
        @archived = obj
      end
      
      def valid?
        values = EventAttributes.map do |event_attribute|
          send(event_attribute)
        end
        values.all?
      end

      def set(params)
        params.each_pair do |pk, pv|
          pv = pv.to_i if pv.kind_of?(String) and pv =~ /^\d+$/
          send("#{pk}=", pv)
        end
        self
      end

      def to_hash
        ret = {  }
        instance_variables.each{ |iv|
          nk = iv.to_s.sub("@", "").to_sym
          ret[nk] = instance_variable_get(iv)
        }
        ret
      end

      def update(params)
        normalized_params = Event.normalize_params(params)
        newtype = normalized_params.delete(:type)
        newtype = newtype.to_sym if newtype

        retclz = self
        if newtype and newtype != type
          retclz = Event.find_for_type(newtype).new
        end
        retclz.set(to_hash.merge(normalized_params))

        if @image
          retclz.instance_variable_set("@image", image.cleaned)
        end
        retclz
      end

      def filename=(obj)
        @filename = obj
      end
      
      def filename
        return @filename if @filename
        "%s%s-%s.%s" % [
          File.join("events",
                    start_date.strftime("%y"),
                    start_date.strftime("%m"),
                    "/"),
          start_date.strftime("%d"),
          slug,
          "yaml"
        ]
      end

      def to_yaml
        YAML::dump(self)
      end

      def exist?
        ::File.exist?(Habitat.adapter(:booking).repository_path(filename))
      end

      def start_date
        dates.first.begin_date rescue Time.now
      end

      def date_identifier
        Booking.date_identifier(start_date)
      end

      def end_date
        dates.first.end_date rescue Time.now
      end

      def current_slot_date
        unless selected_date
          self.for_date(@dates.first.begin_date.to_date.to_s)
        end

        ret = @dates.select{ |drange| selected_date == drange.begin_date.to_date }
        ret.shift
      end

      def html_date(what = :start_date)
        if what.kind_of?(Symbol)
          send(what).form_date
        elsif what.kind_of?(Time)
          what.form_date
        else raise "dont know what to do with #{PP.pp(what, '')}"
        end
      end

      def self.type
        name.split("::").last.downcase.to_sym
      end

      def type
        self.class.type
      end

      def human_type
        type.to_s.capitalize
      end

      def css_class
        gone = @dates.all? { |dr| dr.is_past? }
        "e-%s %s %s %s" % [type.to_s,
                           published? ? "" : "unpublished",
                           (gone and not archived?) ? "event-is-gone" : "",
                           archived? ? "archived" : ""
                          ]
      end

      def dom_uniq_id(add = nil)
        ret = "ev-#{slug}"
        ret << "-#{add}" if add
        ret
      end

      def repetitive?
        false
      end

      def recurrent?
        repetitive?
      end

      def self.default?
        type == :group
      end

      def dates=(hash)
        if hash.kind_of?(Array)
          @dates = hash
          return @dates
        end

        @dates = []
        normalized_hash = Event.normalize_params(hash)
        normalized_hash[:begin].each_with_index do |bdate, i|
          @dates << DateRange.new(bdate, normalized_hash[:end][i])
        end
        @dates
      end

      def set_date(slot, date_to_set)
        case slot
        when :start
          if repetitive?
            @dates[0] = DateRange.new(date_to_set, @dates[0].end_date)
          end
        when :end
          if repetitive?
            @dates[0] = DateRange.new(@dates[0].start_date, date_to_set)
          end
        end
      end

      def start_date=(obj)
        set_date(:start, obj)
      end

      def end_date=(obj)
        set_date(:end, obj)
      end

      def for_date(datestr)
        @selected_date = Date.parse(datestr)
        self
      end

      def is_parent?
        [Recurrent, Event].map{ |pc| self.class == pc }.any?
      end

      def relative_datapath(*args)
        ::File.join("data/events/#{slug}", *args)
      end

      def datapath(*args)
        Habitat.quart.media_path(relative_datapath, *args)
      end

      def intro
        content.split("\n").first
      end

      def image
        @image.event = self
        @image
      rescue
        @image = NoImage.new
      end

      def has_image?
        image.class != NoImage
      end

      def image=(obj)
        return obj if obj.kind_of?(Image)
        upload(obj, obj[:tempfile])
        self
      end

      def upload(obj, path = nil)
        raise "event tries to upload but is not initialized properly (slug unset)" if not slug or slug.empty?
        img = Image.new(path || obj.path)
        img.copy_to(self)
        @image = img
        self
      end

      def template
        default_template_file = "events/default"
        mp = ::File.basename(Habitat::S Habitat.quart.media_path)
        template_file = ::File.join("../../../", mp, "booking/templates", type.to_s)
        if ::File.exist?(Habitat.adapter(:booking).repository_path("templates", "%s.html.haml" % type.to_s))
          template_file
        else
          default_template_file
        end
      end

      def html_text
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true, footnotes: false)
        r = markdown.render(content.strip)
      end

      def corresponding_page
        nil
      end
    end

    class Recurrent < Event 
      def initialize
        super
        @dates = []
      end

      def repetitive?
        true
      end
    end

    def padmonth(i)
      if i
        i.to_s.rjust(2, "0")
      else
        nil
      end
    end
    private :padmonth

    def padyear(i)
      return nil unless i
      ys = i.to_s
      ys.size == 4 ? ys[2..4] : ys
    end
    private :padyear


    def initialize(adapter, year: Time.now.strftime("%y"), month: Time.now.strftime("%m"))
      @adapter = adapter
      @year = padyear(year)
      @month = padmonth(month)
      @read = false
    end

    def read
      @read = true
      replace(directory_files.map{|df| YAML::load(File.readlines(df).join)})
      self
    end

    def _new(arr)
      Events.new(@adapter, year: @year, month: @month).push(*arr)
    end

    def sorted(reverse = false)
      new_sorted = sort_by{|ev| ev.start_date}
      new_sorted = new_sorted.reverse if reverse
      ret = _new(new_sorted)
    end

    def filter(&blk)
      ret = Events.new(@adapter, year: @year, month: @month)
      eles = select{|ev|
        yield ev
      }
      ret.push(*eles)
      # return ret.shift if ret.size == 1
      ret
    end

    def by_slug(slug)
      ret = filter {|ev| ev.slug == slug}
      return ret.shift if ret.kind_of?(Array)
      ret
    end

    class Agenda < Hash
      def initialize(events)
        @events = events
        transform(@events)
      end

      def transform(events)
        merge_proc = lambda {|ev, identdate|
          (self[identdate] ||= Events.new(Habitat.adapter(:booking))) << ev.dup.for_date(identdate)
        }
        events.each do |ev|
          if ev.recurrent?
            ev.dates.each do |daterange|
              merge_proc.call(ev, daterange.date_identifier)
            end
          else
            merge_proc.call(ev, ev.date_identifier)
          end
        end
      end

      def each(&blk)
        sorted_keys = keys.sort
        sorted_keys.each do |k|
          yield k, self[k].sorted.uniq
        end
      end

      def filter(&blk)
        @events = @events.filter(&blk)
        self
      end
    end

    def agenda_list
      Agenda.new(self)
    end

    def find_or_create(params)
      by_slug(params[:slug]) || Event.new.set(params.to_hash)
    end

    def has_range?
      not [@year, @month].map{ |part| part and part != "" and part or nil}.compact.empty?
    end

    def directory
      Habitat.adapter(:booking).repository_path("events", *[@year, @month].compact)
    end
    
    def directory_glob
      args = has_range? ? [@year, @month] : ["/**"]
      ret = Habitat.adapter(:booking).repository_path("events", *args)
      ret << "/**/*.yaml"
    end

    def directory_files
      Dir.glob(directory_glob).reject{|ef| ef[0..1] == "."}
    end
  end

  class ArchivedEvents < Events

    def self.relative_path(*args)
      ::File.join("archive/events", *args)
    end

    def self.path(*args)
      adapter_path = Habitat.adapter(:booking).repository_path( relative_path )
      ::FileUtils.mkdir_p(adapter_path, :verbose => true) unless ::File.directory?(adapter_path)
      ::File.join(adapter_path, *args)
    end

    def self.event_filename(what)
      "%s---%s" % [what.date_identifier, ::File.basename(what.filename)]
    end

    def directory_glob
      "%s/*.yaml" % ArchivedEvents.path
    end

    def read
      super
      each { |ev|
        ev.archived = true
        ev.filename = ArchivedEvents.relative_path( ArchivedEvents.event_filename(ev) )
      }
      self
    end


  end

end
