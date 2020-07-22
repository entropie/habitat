# coding: utf-8
module T

  DEFAULT_YAML_FILENAME = "t.yaml".freeze

  BACKEND_TS = {
                :"galleries-page-topic-index" => "Gallerien und Bilder",
                :"galleries-page-topic-show" => "%s Gallerien und Bilder",
                :"galleries-page-label-upload" => "Hinzufügen",
                :"blog-page-topic-index" => "Blogposts",
                :"snippets-page-topic-index" => "Textausschnitte und Seiten",
                :"user-page-topic-index" => "Benutzer und Admins"

  }


  def self.read
    file_to_read = Habitat.quart.media_path(DEFAULT_YAML_FILENAME)


    loaded = {}
    unless File.exist?(file_to_read)
      Habitat.log :warn, "yaml file not existing #{file_to_read}\nremove 'T' from plugins or create one"
    else
      Habitat.log :info, "reading translation file #{file_to_read}"
      loaded = YAML::load_file(file_to_read)      
    end

    @thash = THash.new.merge(loaded).merge(BACKEND_TS)
  end

  def self.clear
    @thash = nil
  end


  def self.to_hash
    @thash
  end

  class THash < Hash
  end

  def self.included?(arg)
    not T.to_hash[arg.to_sym].nil?
  end
  
end


def t(arg, args = [])
  ret = T.to_hash[arg.to_sym]

  ret = ret % args if args.size > 0
  
  if ret
    return self.respond_to?(:_raw) ? _raw(ret) : ret
  end
  return self.respond_to?(:_raw) ? _raw("<span style='color:red'>#{arg}</span>") : arg
end

T.read

