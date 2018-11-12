# coding: utf-8

module Felle

  module ControllerMethods

    def felle(*args, &blk)
      adapter(:felle).with_user(session_user, &blk)
    end

    def create_fell_from_params(params)
      mktime = -> (s) { Time.parse(s) rescue nil }

      ts, te = mktime.call(params[:datestart]), mktime.call(params[:dateend])

      fell = felle.create(params[:name],
                          attributes: params[:attributes],
                          breed: params[:breed],
                          origin: params[:origin],
                          gender: params[:gender],
                          birthday: (ts && te ? ts .. te : ts),
                          state: params[:state].to_i)
      unless fell.valid?
        p fell.missing_fields
        raise "invalid dataset, probably due to missing fields"
      end
      fell
    end


    def update_fell_from_params(fell, params)
      felle.update(fell, params)
      fell
    end
    
  end
  
  class Fell

    class FellBday
      def initialize(date_or_range)
        @date_or_range = date_or_range
      end


      def age(dob)
        now = Time.now.utc.to_date
        now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
      end

      def to_age
        tfmt = "%Y-%m"
        if @date_or_range.kind_of?(Range)
          la = age(@date_or_range.last)
          fa = age(@date_or_range.first)
          if la != fa
            "%s bis %s" % [la, fa]
          else
            fa
          end
        else
          age(@date_or_range)
        end
      end

      def value_end
        if @date_or_range.kind_of?(Range)
          @date_or_range.last
        else
          nil
        end
      end

      def value_start
        if @date_or_range.kind_of?(Range)
          @date_or_range.first
        else
          @date_or_range
        end
      end
    end

    class ChangeMessage
      def initialize(msg, sc, author = SF)
        @sc = sc
        @date, @msg, @author = Time.now, msg, author
      end

      def to_s
        "<div class='logmsg'><div class='date'>%s</div><div class='text'>%s</div><div class='author'>%s</div></div>" %
          [@date, @msg, (@sc || @author).name]
      end
    end

    Attributes = [:neutered, :hd, :ailments, :medication, :pedigree]

    Male   = 0
    Female = 1

    STATES = {
      0 => "suchen",
      9 => "gefunden",
      3 => "ausserhalb",
      4 => "vorbehalt",
      7 => "verstorben",
      8 => "system"
    }

    STATES_TRANSLATED = {
      0 => "Auf der suche",
      9 => "Schon angekommen",
      3 => "Vereinsfremde",
      4 => "Unter Vorbehalt",
      8 => "System",
      7 => "Regenbogenbrücke",
    }

    
    class FellAttributes < Hash
      def initialize
        Attributes.each do |a|
          self[a] = 0
        end
        super()
      end
    end

    attr_reader   :name, :created_at, :gender
    attr_accessor :updated_at, :birthday, :state
    attr_accessor :breed, :origin, :attributes
    attr_accessor :panorama_image, :scoville
    attr_accessor :adapter

    def gender_human
      @gender == 0 ? "Männlich" : "Weiblich"
    end
    
    def self.make_slug(str)
      str.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end

    def create(force = false)
      FileUtils.mkdir_p(root, :verbose => true)
      update
    end

    def set(k, v)
      instance_variable_set("@#{k}", v)
      update
      self
    end
    
    def human_state
      Fell.human_state(self)
    end

    def update
      [:name, :birthday, :gender].each { |important_attrib|
        send(important_attrib).to_s.strip.empty? and raise "deine mama"
      }
        
      puts "> writing #{yaml_source}"
      @updated_at = Time.now
      File.open(text_file,   "w+"){|fp| fp.puts(text)}
      File.open(yaml_source, "w+"){|fp| fp.puts(to_yaml )}
    end

    def asset_path(*args)
      root("assets", *args)
    end

    def images
      Dir.glob(datadir("images") + "/" + "*.*").map {|imgfile|
        Image.from_datadir(self, imgfile)
      }
    end

    def upload(obj)
      img = Image.new(obj.path)
      img.copy_to(self)
      @image = img
    end
    
    def scoville
      @scoville || 0
    end

    # def rateyo_html(readonly = true)
    #   ro = if readonly then "1" else "0" end
    #   url = File.join("/felle/hund/set/", slug, "scoville")
    #   %Q*<div class="rateYo" data-scoville="%s" data-url="%s" data-ro="%s"></div>* % [scoville, url, ro]
    # end

    def yaml_source
      root("metadata.yaml")
    end

    def text_file
      root("content.markdown")
    end

    def root=(arg)
      @root = arg
    end

    def root(*args)
      File.join(@root || adapter.repository_path(slug), *args)
    end

    def gender=(fixn)
      raise "'#{fixn}' not a gender" unless [ Felle::Fell::Male, Felle::Fell::Female ].include?(fixn.to_i)
      @gender = fixn
    end

    def datadir=(arg)
      @datadir = arg
    end

    def datadir(*args)
      File.join(@datadir || adapter.datadir(slug), *args)
    end

    def http_path(*args)
      File.join("/felle", STATES[state], slug)
    end

    def stateslug
      STATES[state.to_i]
    end

    def http_datadir(*args)
      File.join("/assets/felle/data", slug)
    end

    def yaml_file
      root("metadata.yaml")
    end

    def exist?
      File.exist?(yaml_file)
    end

    def missing_fields
      v = [:name, :birthday, :breed, :origin, :gender].map do |at|
        val = self.send(at)
        if not val or val.to_s.strip.empty? then at else nil end
      end.compact
      v
    end

    def valid?
      missing_fields.empty?
    end
    
    def initialize(name = nil)
      self.name = name if name
      @created_at = Time.now
      @log = []
      attributes
    end

    def log
      @log ||= []
    end

    def add_log(msg, author)
      log << ChangeMessage.new(msg, author)
    end

    def name=(obj)
      @name = obj
    end

    def state
      @state
    end

    def short_description
      "#{name} sucht ein Zuhause."
    end

    def slug
      @slug ||= Fell.make_slug(name)
    end

    def attributes
      @attributes ||= FellAttributes.new
    end

    def attributes=(hash)
      attributes
      hash.each_pair{|hk,hv| hash[hk.to_sym] = hv.to_i}
      @attributes = FellAttributes.new.merge!(hash)
      @attributes
    end

    def birthday=(time_or_range)
      @birthday = FellBday.new(time_or_range)
    end

    def birthday_end
      @birthday.value_end
    end

    def birthday_start
      @birthday.value_start
    end

    def age
      birthday.to_age
    end

    def draft?
      false
    end

    def text
      @text ||= File.readlines(text_file).join rescue "default text"
    end

    def text=(obj)
      @text = obj
    end

    def self.with_markdown(str, r = Redcarpet::Render::HTML)
      markdown = Redcarpet::Markdown.new(r, :tables => true, :footnotes => true)
      markdown.render(str)
    end

    def to_html
      Fell.with_markdown(text)
    end

    def to_yaml
      remove_instance_variable("@adapter") rescue nil
      super
    end
  end

  class Hund < Fell
    def page_title
      "Hund &mdash; %s" % [name]
    end
  end

  class Katze < Fell
    def page_title
      "Katze &mdash; %s" % name
    end
  end

end
  
