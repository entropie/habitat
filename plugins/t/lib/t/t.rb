module T

  DEFAULT_YAML_FILENAME = "t.yaml".freeze

  BACKEND_TS = {
                :"galleries-page-topic-index" => "Gallerien und Bilder",
                :"blog-page-topic-index" => "Blogposts",
                :"snippets-page-topic-index" => "Textausschnitte und Seiten",
                :"user-page-topic-index" => "Benutzer und Admins"

  }


  def self.read
    file_to_read = Habitat.quart.media_path(DEFAULT_YAML_FILENAME)

    loaded = YAML::load_file(file_to_read)

    Habitat.log :info, "reading translation file #{file_to_read}"
    if not File.exist?(file_to_read) or !loaded
      puts "yaml file not existing #{file_to_read}\nremove #{self.class.to_s} from plugins or create one"
      sleep 5
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


def t(arg)

  if ret = T.to_hash[arg.to_sym]
    return ret
  end
  return "<span style='color:red'>#{arg}</span>"
end

T.read

