require "webp-ffi"

module Webp

  def self.encode(complete_filename)
    name, extname = ::File.basename(complete_filename).split(".")
    webp_filename = ::File.join(File.dirname(complete_filename), "%s.%s" % [name, "webp"])
    unless File.exist?(webp_filename)
      Habitat.log :debug, "WEBP:image generating webp for #{complete_filename}"
      WebP.encode(complete_filename, webp_filename)
    end
    webp_filename
  end

  def webp_url
    Webp.encode(fullpath)
    urlwoext, ext = http_path.split(".")
    urlwoext + ".webp"
  end
  
end
