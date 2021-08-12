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

      def end_date_p
        end_date.form_date
      end

      def date_identifier
        Booking.date_identifier(begin_date)
      end
    end

    class Event

      EventAttributes = [
        :title,
        :slug,
        :dates,
        :protagonists,
        :attender_slots
      ]

      DataAttributes = [
        :content
      ]

      attr_accessor *EventAttributes
      attr_accessor *DataAttributes

      attr_accessor :published

      attr_accessor   :updated_at, :created_at

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
        type = paramhash.delete(:type)
        if type
          created_event = find_for_type(type)
        end

        ev = created_event.new
        ev.set(paramhash)
        ev
      end

      def initialize
        @created_at = Time.now
        @published = false
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

      
      def valid?
        values = EventAttributes.map do |event_attribute|
          send(event_attribute)
        end
        values.all?
      end

      def set(params)
        params.each_pair do |pk, pv|
          pv = Time.parse(pv) if not pv.kind_of?(Time) and pk.to_s =~ /date$/
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
        retclz
      end

      def filename
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
        "e-%s %s" % [type.to_s, published? ? "" : "unpublished"]
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

      # actually only used in Recurrent events but in parent class to not lose dates when switching types
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
      return ret.shift if ret.size == 1
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
        events.each do |ev|
          if ev.recurrent?
            ev.dates.each do |daterange|
              self[daterange.date_identifier] ||= Events.new(Habitat.adapter(:booking))
              self[daterange.date_identifier] << ev
            end
          else
            self[ev.date_identifier] ||= Events.new(Habitat.adapter(:booking))
            self[ev.date_identifier] << ev
          end
        end
      end

      def each(&blk)
        sorted_keys = keys.sort
        sorted_keys.each do |k|
          yield k, self[k].sorted.uniq
        end
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

end
