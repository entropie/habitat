module Stars

  module Database

    extend Habitat::Database

    class Adapter

      class File < Habitat::Database::Adapter

        include Habitat::Mixins::FU

        STAR_EXTENSION = ".star.yaml"
        
        def initialize(path)
          @path = path
        end

        def path(*args)
          ::File.join(@path, *args)
        end

        def setup
          @setup = true
          log :debug, "setting up adapter directory #{path}"
          FileUtils.mkdir_p(path)
          @setup
        end

        def repository_path(*args)
          ::File.join(::File.realpath(path), "stars", *args)
        rescue Errno::ENOENT
          warn "does not exist: #{path("blog")}"
          path("stars", *args)
        end

        def star_filename(ident = nil)
          repository_path("%s%s" % [ident || ident, STAR_EXTENSION])
        end

        def exist?(post)
          ::File.exist?(post_filename(post))
        end

        def stars_files
          toglob = repository_path + "/*" + STAR_EXTENSION + "*"
          Dir.glob(toglob)
        end

        def grep(obj)
          str = obj.to_s
          stars.select{|s| s.ident.to_s.include?(str) }
        end
        
        def exist?(obj)
          not select(obj).kind_of?(NotExistingStar)
        end

        def stars
          ::Stars::Stars.new(stars_files.map{|sf| ::Stars::Star.for(sf) })
        end

        # def [](ident)
        #   slug_ident = ::Habitat::Database::make_slug(ident)
        #   stars.select{|star| star.ident == slug_ident}
        # end

        def load_file(yamlfile)
          log :debug, "loading #{Habitat.S(yamlfile)}"
          YAML::load_file(yamlfile)
        end

        def create(ident, ohash = {})
          star = Star.new(ident)
          raise StarAlreadyExist, "star already existing" if star.exist?

          star.merge(ohash)
          store(star)
          star
        end

        def update_or_create(hsh)
          slug_ident = hsh.delete(:ident)
          star = stars[slug_ident]

          if star.kind_of?(NotExistingStar)
            log :info, "stars:CREAT:#{star.ident}"
            star = star.create(hsh)
          else
            star.merge(hsh)
            log :info, "stars:UPDAT:#{star.ident}"
          end

          store(star)
          star
        end

        def store(star)
          log :info, "stars:STORE:#{star.ident}"
          file = repository_path(star.filename)
          FileUtils.mkdir_p(::File.dirname(file), :verbose => true) unless ::File.dirname(file)
          write(file, YAML::dump(star))
        end

        def destroy(star)
          log :info, "star:REMOVE:#{star.ident}"
          rm(repository_path(star.filename), :verbose => true)
        end
      end

    end

  end

end
