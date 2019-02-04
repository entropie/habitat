
module Galleries

  module GalleryPresenter
    include Hanami::Helpers::HtmlHelper

    def gallery_dom_id
      "gallery-#{ident}"
    end

    def image_dom_id(img)
      "gallery-image-#{img.hash}"
    end

    def select_images(except, only)
      ret = images

      except, only = [except].flatten, [only].flatten

      if not only.empty?
        only.each do |oi|
          ret = ret.select{|i| i == oi}
        end
      elsif not except.empty?
        except.each do |ei|
          ret = ret.delete_if{|i| i == ei}
        end
      end

      ret      
    end


    def to_html(except: [], only: [])

      filtered = select_images(except, only)
      
      html.div(:class => "gallery #{gallery_dom_id}") do 
        filtered.each do |img|
          div(:class => "gallery-img-container") do
            a(:href => img.url) do
              img(:src => img.url)
            end
          end
        end
        
      end
    end
  end


  def IMG(gal, ident)
    gallery = Habitat.adapter(:galleries).find(gal)
    img = gallery.images(ident)

    msg = ""
    if !gallery
      msg = "gallery <i>#{gal}</i> not existing"
    elsif !img
      msg = "image <i>#{ident}</i> not existing in gallery <i>#{gal}</i>."
    else
      return "<img class='gi g-#{gal}' src='#{img.url}' />"      
    end

    return "<div class='error-msg'>#{msg}</div>"
  end

  def GALLERY(name, except: [], only: [])
    gallery = Habitat.adapter(:galleries).find(name.to_s)
    gallery = gallery.extend(GalleryPresenter)
    gallery.to_html(except: except, only: only)
  rescue Habitat::Database::EntryNotValid
    return "<div class='error-msg'>Gallery: <i>#{name}</i> not existing</div>."
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

    def remove_image(image)
      self[:images] = self[:images].dup.delete_if{|h, img| img == image }
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

      def delete
        FileUtils.rm_rf(path, :verbose => true)
      end

      def path
        @gallery.path(".." ,@filename)
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

      def ==(obj)
        if obj.kind_of?(Image)
          self == obj.hash
        else
          ident == obj or @hash == obj
        end
      end
    end


    attr_reader :ident
    attr_accessor :adapter
    attr_accessor :user
    attr_reader :metadata

    def file_exist?(f)
      File.exist?(path(f))
    end

    def exist?
      File.exist?(path)
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
      metadata.images[img.hash].ident = ident
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

    def remove(img_or_imghash)
      hash = img_or_imghash
      if img_or_imghash.kind_of?(Image)
        hash = img_or_imghash.hash
      end
      img = images(hash)
      metadata.remove_image(img)
      img.delete
      self
    end
    
  end
  
end
