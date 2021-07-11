module Webp

  def self.encode(complete_filename)
    name, extname = ::File.basename(complete_filename).split(".")
    webp_filename = ::File.join(File.dirname(complete_filename), "%s.%s" % [name, "webp"])
    unless File.exist?(webp_filename)
      Habitat.log :debug, "WEBP:image generating webp for #{fullpath}"
      WebP.encode(fullpath, webp_filename)
    end
    webp_filename
  end

  def webp_url
    File.join("/attachments", dirname, ::File.basename(fullpath).split(".").first + ".webp")
  end
  
end
