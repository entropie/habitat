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

        def create(ident, n, content, ohash = {})
          slug_ident = ::Habitat::Database::make_slug(ident)
          star = Star.new(slug_ident, n.to_i, content)
          raise StarAlreadyExist, "star already existing" if star.exist?

          star.image = img if img = ohash[:image]

          store(star)
          star
        end

        def update_or_create(hsh)
          i, n, content = hsh.fetch_values(:ident, :stars, :content)
          slug_ident = ::Habitat::Database::make_slug(i)
          n = n.to_i

          star = stars[slug_ident]

          if not star
            star = create(slug_ident, n, content)
          else
            star.stars = n
            star.content = content
            log :info, "stars:UPDAT:#{star.ident}"
          end

          star.image = hsh[:image] if hsh[:image]

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
