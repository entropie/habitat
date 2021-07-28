module Booking

  class Workday

    attr_accessor :updated_at, :created_at

    class Slots < Array
      def [](obj)
        select{|s| s.slot == obj}.first
      end
    end

    class Entry
      DataFields = [:phone, :email, :name, :location]

      attr_accessor *DataFields

      attr_reader   :slot
      
      def initialize(workday, slot)
        @workday = workday
        @slot  = slot
      end

      def inspect
        "<#{self.class.name.to_s.split("::").last}(%s): %s - {#{additional}}>" % [@workday.datestr, @slot]
      end

      def additional
        ""
      end

      def merge(hsh)
        hsh.each_pair do |hk, hv|
          send("#{hk}=", hv)
        end
        self
      end

      def blocked?
        false
      end

      def available?
        true
      end
    end

    class Blocked < Entry
      def available?
        false
      end

      def blocked?
        true
      end
    end

    class Available < Entry
    end
    
    class Single < Available
      def available?
        false
      end

      def additional
        DataFields.map{|hk|
          "%s='%s'" % [hk, send(hk) || ""]
        }.join(", ")
      end
    end


    attr_accessor :date
    attr_accessor :slots

    def initialize(year, month, day)
      @date = Time.new(year, month, day)
      slots # initialize @slots for yaml
    end

    def valid?
      true
    end

    def datestr
      date.strftime("%y-%m-%d")
    end

    def slug
      datestr
    end

    def filename
      File.join("workdays", date.strftime("%y"), date.strftime("%m"), "%s.yaml" % date.strftime("%d"))
    end

    def exist?
      ::File.exist?(Habitat.adapter(:booking).repository_path(filename))
    end
    
    def slots
      @slots ||= Slots.new.push(*Workday::default_slots.map{|s| Available.new(self, s) })
    end

    def set_slot(slot, what)
      Habitat.log :debug, "slots[#{datestr}]:set:#{slot}: #{what.class}"
      tele = slots.select{|sl| sl.slot == slot }.first
      raise "trying to fill not existing slot" unless tele
      slots[slots.index(tele)] = what
      what
    end

    def fill(whereby, slot)
      set_slot(slot, whereby.new(self, slot))
    end

    def self.load_workday(wd)
      Habitat.log :info, "reading workday[#{wd.filename}]"
      YAML::load(File.readlines(Habitat.adapter(:booking).repository_path(wd.filename)).join)
    end

    def self.read_or_new(*args)
      workday = Workday.new(*args)
      if workday.exist?
        load_workday(workday)
      else
        workday
      end
    end

    def self.default_slots
      yaml_file = Habitat.quart.media_path("slots.yaml")
      if ::File.exist?(yaml_file)
        Habitat.log :info, "booking: reading workdays from #{Habitat.S(yaml_file)}"
        @default_slots = YAML::load_file(yaml_file)
      else
        #ile.open(yaml_file, "w+"){ |fp| fp.puts(YAML.dump([10, 12, 14, 16, 18])) }
        Habitat.log :warn, "no slots.yaml: #{Habitat.S(yaml_file)}"
        @default_slots = [10, 12, 14, 16, 18]
      end
    end
    
  end
end
