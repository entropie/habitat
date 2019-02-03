
module Galleries

  def IMG(gal, ident)
    img = Habitat.adapter(:galleries).find_or_create(gal).images(ident)
    "<img class='gi g-#{gal}' src='#{img.url}' />"
  end


  module ControllerMethods
    def galleries
      Habitat.adapter(:galleries)
    end
  end


  DEFAULT_ADAPTER = :File

  class Galleries < Array
  end

  def log(a)
    Habitat.log(:info, a)
  end

  class Metadata < Hash
    def initialize
    end

    def add_image(image)
      self[:images].merge!(image.hash => image)
      self
    end

    def images
      self[:images]
    end

    def self.create(gallery)
      Metadata.new.
        merge(
          :name => gallery.ident,
          :images => {}
        )
    end
  end


  class Gallery
    include ::Galleries

    class Image
      attr_reader :filename
      attr_reader :gallery

      def initialize(filename, gallery)
        @filename = filename
        @gallery = gallery
      end

      def hash
        @hash ||= File.basename(filename).split(".").first
      end

      def self.hash_filename(file)
        ret = Digest::SHA1.hexdigest(File.new(file).read) + File.extname(file).downcase
      end

      def url
        File.join(Habitat.quart.default_application.routes.gallery_path, filename)
      end

      def ident
        @ident || hash
      end

      def ident=(obj)
        @ident = obj.to_s
      end

      def ==(hsh)
        ident == hsh
      end
    end

    class Images < Array
    end


    attr_reader :ident
    attr_accessor :adapter
    attr_accessor :user
    attr_reader :metadata

    def file_exist?(f)
      File.exist?(path(f))
    end


    def initialize(ident)
      @ident = ident
    end

    def metadata
      return @metadata if @metadata
      if file_exist?("metadata.yaml")
        @metadata = YAML::load_file(path("metadata.yaml"))
      else
        @metadata = Metadata.create(self)
      end
      @metadata
    end

    def write_metadata
      file = path("metadata.yaml")
      FileUtils.mkdir_p(path, :verbose => true)

      metadata
      File.open(file, "w+") do |fp|
        fp.puts(YAML::dump(metadata))
      end

      log "gallery:#{ident}: writing #{file}"
    end


    def rpath(*args)
      File.join(ident, *args)
    end
    
    def path(*args)
      adapter.repository_path(ident, *args)
    end

    def filename
      path("gallery.yaml")
    end

    def images(imgh = nil)
      if metadata[:images]
        ims = metadata[:images].values
        if imgh
          single_image = ims.select{|i| i == imgh}.first
          if single_image
            return single_image
          end
        else
          ims
        end
      else
        []
      end
    end

    def set_ident(img, ident)
      pp metadata.images[img.hash].ident = ident

    end

    def add(imagepaths)
      ([imagepaths].flatten).each do |imagepath|
        FileUtils.mkdir_p(path("images"), :verbose => true)
        hashed_filename = Image.hash_filename(imagepath)

        relative_path = rpath("images", hashed_filename)
        
        FileUtils.cp(imagepath, path("images", hashed_filename), :verbose => true)
        log "  gallery:#{ident}: adding: #{imagepath} => #{relative_path}"

        metadata.add_image(Image.new(relative_path, self))
      end
    end
    
  end
  
end
