# coding: utf-8
module T

  DEFAULT_YAML_FILENAME = "t.yaml".freeze

  BACKEND_TS = {
                :"galleries-page-topic-index" => "Gallerien und Bilder",
                :"galleries-page-topic-show" => "%s Gallerien und Bilder",
                :"galleries-page-label-upload" => "Hinzufügen",
                :"blog-page-topic-index" => "Blogposts",
                :"blog-page-topic-create" => "Neues Blogpost",
                :"snippets-page-topic-index" => "Textausschnitte und Seiten",
                :"snippets-page-topic-create" => "Snippet Anlegen",
                :"snippet-help-ident" => "einzigartiger bezeichner",
                :"stars-page-topic-index" => "Bewertungen",
                :"stars-page-topic-create" => "Bewertung Anlegen",
                :"t-page-topic-index" => "Variablen und Textschnipsel",
                :"t-page-topic-edit" => "Bearbeiten",
                :"t-page-topic-create" => "Erstellen",
                :"user-page-topic-index" => "Benutzer und Admins"

  }

  def self.default_file
    Habitat.quart.media_path(DEFAULT_YAML_FILENAME)
  end


  def self.translations
    read
  end

  def self.clear
    Habitat.log(:info, "clearing t")
    @translations = nil
  end


  def self.read
    file_to_read = default_file

    unless File.exist?(file_to_read)
      Habitat.log :warn, "yaml file not existing #{file_to_read}\nremove 'T' from plugins or create one"
    else
      Habitat.log :info, "reading translation file #{file_to_read}"
      loaded = YAML::load_file(file_to_read)      
    end
    ret = Translations.from_hash(loaded.merge(BACKEND_TS))

    if Habitat.quart.plugins.enabled?(:cache)
      ret.each do |trans|
        Cache[trans.key] = trans.value
      end
    end
    ret
  end


  def self.sorted(&arg)
    Translations.new.push(*to_a.sort_by{|trans| trans.key.to_s })
  end
  
  def self.to_a
    translations
  end

  def self.update_or_create(params)
    params[:key] = params[:slug] if params[:slug]
    key, value = params.values_at(:key, :value)

    trans = T.translations[key]

    if trans.value != value or trans.kind_of?(NotExistingTrans)
      trans.value = value
      # update needed
      everything = T.translations.reject{|trans| trans.backend_translation? or trans == key}

      all_new = everything.push(trans)
      to_write = Hash[*all_new.map{|t| [t.key, t.value]}.flatten]
      ::FileUtils.cp(default_file, default_file+".bak", :verbose => true)
      Habitat.log(:info, "updating #{default_file}")
      File.open(default_file, "w+"){|fp| fp.puts(YAML::dump(to_write)) }
      read
    end
    trans
  end

  def self.include?(obj)
    s = obj.to_sym
    self[s].exist?
  end
  
  def self.[](obj)
    tobj = obj.to_sym
    if Habitat.quart.plugins.enabled?(:cache)
      cached = Cache[tobj]
      ret = Trans.new(tobj, cached)
      unless cached
        ret = NotExistingTrans.new(tobj)
      end
    else
      ret = read[tobj]
      return ret.to_s
    end
    ret
  end


  class Trans
    attr_reader :key, :value
    def initialize(key, value)
      @key, @value = key, value
    end

    def value=(val)
      @value = val.to_s
    end

    def ==(obj)
      @key == obj.to_sym
    end

    def to_s
      (kind_of?(NotExistingTrans) ? "<span class='snippet-ne'>%s</span>" : "%s") % @value
    end

    def backend_translation?
      BACKEND_TS.include?(@key)
    end

    def exist?
      kind_of?(NotExistingTrans) ? false : true
    end
  end

  class NotExistingTrans < Trans
    def initialize(key)
      @key = key
      @value = "#{key}"
    end

    def exist?
      false
    end
  end
  
  class Translations < Array

    def self.from_hash(hsh)
      ret = Translations.new
      hsh.each do |h,k|
        ret.add(h, k)
      end
      ret
    end

    def include?(obj)
      not select{|t| t == obj}.empty?
    end

    def add(k, v)
      k = k.to_sym
      self << Trans.new(k, v) unless include?(k)
    end

    def [](obj)
      return nil unless obj
      k = obj.to_sym
      ret = select{|trans| trans == k }
      if ret.size > 0
        ret.first
      else
        NotExistingTrans.new(k)
      end
    end
  end


end

def translate(arg, *args)
end

def t(arg, args = [])
  ret = T[arg]
  ret = ret.to_s % args if args.size > 0
  _raw(ret.to_s)
rescue
  ret.to_s
end

T.read
