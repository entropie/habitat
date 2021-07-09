module Booking

  class Events < Array

    class Event

      EventAttributes = [
        :title,
        :slug,
        :start_date,
        :end_date,
        :protagonists,
        :attender_slots
      ]

      DataAttributes = [
        :attender,
        :content
      ]

      attr_accessor *EventAttributes
      attr_accessor *DataAttributes

      attr_accessor   :updated_at, :created_at

      def self.create(paramhash)
        created_event = Event.new
        created_event.set(paramhash)
        created_event
      end

      def initialize
        @created_at = Time.now
      end

      def ident
        slug
      end

      def ident=(o)
        @slug = o
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
          send("#{pk}=", pv)
        end
        self
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
        @start_date ||= Time.now
      end

      def end_date
        @end_date ||= Time.now
      end

      def html_date(what = :start_date)
        format_string = "%Y/%m/%d %H:%M"
        if what.kind_of?(Symbol)
          send(what).strftime(format_string)
        elsif what.kind_of?(Time)
          what.strftime(format_string)
        else raise "dont know what to do with #{PP.pp(what, '')}"
        end
      end
      
    end

    def padmonth(i)
      i.to_s.rjust(2, "0") if i
    end
    private :padmonth

    def padyear(i)
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

    def filter(&blk)
      ret = Events.new(@adapter, year: @year, month: @month)
      eles = select{|ev|
        yield ev
      }
      ret.push(*eles)
      ret.shift
    end

    def find_or_create(params)
      filter {|ev| ev.slug == params[:slug]} || Event.new.set(params.to_hash)
    end
    
    def directory
      Habitat.adapter(:booking).repository_path("events", @year, @month)
    end

    def directory_files
      event_file_glob = directory + "/**/*.yaml"
      Dir.glob(event_file_glob).reject{|ef| ef[0..1] == "."}
    end

  end
end
