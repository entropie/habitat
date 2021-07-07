module Booking

  class Events

    class Event

      EventAttributes = [
        :slug,
        :start_date,
        :end_date,
        :protagonists,
        :attender_slots
      ]

      DataAttributes = [
        :attender
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
      end

      def set(params)
        raise "keys not matching" unless (params.keys - EventAttributes).empty?
        params.each_pair do |pk, pv|
          send("#{pk}=", pv)
        end

        DataAttributes.each do |pk, pv|
          send("#{pk}=", [])          
        end
      end

      def filename
        "%s%s-%s.%s" % [File.join("events",
                                  start_date.strftime("%y"),
                                  @start_date.strftime("%m"), "/"),
                        @start_date.strftime("%d"),
                        @slug,
                        "yaml"]
      end

      def to_yaml
        YAML::dump(self)
      end

      def exist?
        ::File.exist?(Habitat.adapter(:booking).repository_path(filename))
      end
    end

    def padzero(i)
      i.to_s.rjust(2, "0") if i
    end

    def initialize(adapter, year: Time.now.strftime("%y"), month: Time.now.strftime("%m"))
      @adapter = adapter
      @year = year
      @month = padzero(month)
    end

    def read
      @result = directory_files.map{|df| YAML::load(File.readlines(df).join)}
    end

    def to_a
      read unless @result
      @result
    end

    def empty?
      to_a.empty?
    end

    def directory
      adapter.repository_path("events", @year, @month)
    end

    def directory_files
      event_file_glob = directory + "/**/*.yaml"
      Dir.glob(event_file_glob).reject{|ef| ef[0..1] == "."}
    end

  end
end
