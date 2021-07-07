module Booking


  module Database

    extend Habitat::Database

    class Adapter

      class File < Habitat::Database::Adapter

        include Habitat::Mixins::FU

        # SNIPPET_EXTENSION = ".snippet."
        
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
          ::File.join(::File.realpath(path), "booking", *args.compact.map(&:to_s))
        rescue Errno::ENOENT
          warn "does not exist: #{path("blog")}"
          path("booking", *args)
        end

        # def snippet_filename(ident = nil)
        #   repository_path("%s%s" % [ident || ident, SNIPPET_EXTENSION])
        # End


        def events(year: Time.now.strftime("%y"), month: Time.now.strftime("%m"), day: Time.now.strftime("%m"))
          evs = ::Booking::Events.new(self, year: year, month: month, day: day)
        end

        def load_file(yamlfile)
          # log :debug, "loading #{Habitat.S(yamlfile)}"
          # YAML::load_file(yamlfile)
        end

        def create(what, params)
          ret = case what
                when :event
                  ::Booking::Events::Event.create(params)
                end
          # snippet = adapter_class(kind).new(ident).extend(SnippetCreater)
          # store(snippet, content)
        end

        # def update_or_create(ident, param_hash)
        #   snippet = adapter_class(kind).new(ident).extend(SnippetCreater)
        #   store(snippet, content)
        # end

        def store(snippet, content)
          log :info, "snippet:STORE:#{snippet.ident}"
          file = repository_path(snippet.filename)
          # FileUtils.mkdir_p(::File.dirname(file), :verbose => true) unless ::File.dirname(file)
          # write(file, content)
        end

        def destroy(snippet)
          log :info, "snippet:REMOVE:#{snippet.ident}"
          # rm(repository_path(snippet.filename), :verbose => true)
        end
      end

    end

  end

end
