
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

    def to_slider(except: [], only: [], images: nil)
      filtered = images || select_images(except, only)

      html.div(:class => "gallery-slider") do
        ul(:class => "gallery-thumbnails") do
          filtered.each_with_index do |img, index|
            li do
              a(:href => img.url, :style => img.css_background_defintion, :class => "popupImg")
            end
          end
        end

        div(:class => "gallery-thumbnail-box") do
          ul(:class => "thumbs") do
            filtered.each_with_index do |img, index|
              li do
                a(:href => "##{index+1}", "data-slide" => index+1, :style => img.css_background_defintion)
              end
            end
          end
        end
      end
    end
  end

  module GalleriesAccessMethods

    def CSS_BACKGROUND(gal, ident)
      gallery = Habitat.adapter(:galleries).find(gal)
      img = gallery.images(ident)

      msg = ""
      if !gallery
        msg = "gallery <i>#{gal}</i> not existing"
      elsif !img
        msg = "image <i>#{ident}</i> not existing in gallery <i>#{gal}</i>."
      else
        begin
          return _raw(img.css_background_defintion)
        rescue
          return img.css_background_defintion
        end
      end
    end
    

    def IMGSRC(gal, ident)
      gallery = Habitat.adapter(:galleries).find(gal)
      img = gallery.images(ident)

      msg = ""
      if !gallery
        msg = "gallery <i>#{gal}</i> not existing"
      elsif !img
        msg = "image <i>#{ident}</i> not existing in gallery <i>#{gal}</i>."
      else
        begin
          return _raw(img.url)
        rescue
          return img.url
        end
      end

      return "<div class='error-msg'>#{msg}</div>"
    end

    def IMG(gal, ident, hsh = {  })
      gallery = Habitat.adapter(:galleries).find(gal)
      img = gallery.images(ident)

      msg = ""
      if !gallery
        msg = "gallery <i>#{gal}</i> not existing"
      elsif !img
        msg = "image <i>#{ident}</i> not existing in gallery <i>#{gal}</i>."
      else
        acss = hsh.map{ |h,k| "#{h}:#{k}" }.join(";")
        return "<div id='#{img.dom_id}' href='#{img.url}' class='popupImg' style='background-image: url(#{img.url});#{acss}'></div>"
      end

      return "<div class='error-msg'>#{msg}</div>"
    end

    def SliderGallery(name, except: [], only: [], &blk)
      gallery = Habitat.adapter(:galleries).find(name.to_s)
      gallery = gallery.extend(GalleryPresenter)


      # if there is only a single image in gallery, we dont need to show the entire gallery
      # but the single img (dispatch to #IMG)
      if (imgs = gallery.select_images(except, only)).size == 1
        return IMG(name.to_s, imgs.first.hash)
      end

      gallery.to_slider(except: except, only: only, images: imgs)
    rescue Habitat::Database::EntryNotValid
      return "<div class='error-msg'>Gallery: <i>#{name}</i> not existing</div>."
    end

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
      end

      def hash
        @hash ||= File.basename(filename).split(".").first
      end

      def delete
        FileUtils.rm_rf(path, :verbose => true)
      end

      def gallery
        Habitat.adapter(:galleries).find(@filename.split("/").first)
      end
      
      def path
        Habitat.adapter(:galleries).repository_path(@filename)
      end

      def size
        ::File.size(path)
      end

      def human_size
        '%.2f' % (size.to_f / 2**20)
      end

      def fullpath
        path
      end

      def self.hash_filename(file)
        ret = Digest::SHA1.hexdigest(File.new(file).read) + File.extname(file).downcase
      end

      def http_path(*args)
        raise "Habitat.quart.default_application unset" unless Habitat.quart.default_application
        File.join(Habitat.quart.default_application.routes.gallery_path, @filename)
      end
      
      def url
        if Habitat.quart.plugins.enabled?(:webp)
          extend(Webp)
          webp_url
        else
          http_path
        end
      end

      def css_background_defintion
        retstr = "background-image: url(%s)" % url
        if Habitat.quart.plugins.enabled?(:webp)
          extend(Webp)
          retstr << ";background-image: url(%s)" % webp_url
        end
        retstr
      end
      
      def ident
        @ident || hash
      end

      def ident=(obj)
        @ident = obj.to_s
      end

      def dom_id
        "gallery-%s" % [ident]
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
      if existing_image = images(ident)
        raise Habitat::Database::DataBaseError,
              "ident '#{ident}' already set for #{existing_image.hash} : #{existing_image.filename}"
      end
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
