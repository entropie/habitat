module Booking


  module Database

    extend Habitat::Database

    class Adapter

      class File < Habitat::Database::Adapter

        include Habitat::Mixins::FU

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

        def events(year: Time.now.strftime("%y"), month: Time.now.strftime("%m"), day: Time.now.strftime("%d"))
          evs = ::Booking::Events.new(self, year: year, month: month, day: day)
        end

        def create(what, params)
          tclazz = case what
                   when :event
                     ::Booking::Events::Event
                   end
          to_create = tclazz.create(params)
          store(to_create)
          to_create
        end

        def update_or_create(ident, param_hash)
          raise "not implemented"
        end

        def store(what)
          raise NoUserContext, "trying to call #store without valid user context " unless @user

          target_file = repository_path(what.filename)
          mkdir_p(::File.dirname(target_file))

          if what.exist?
            what.updated_at = Time.now
          else
            what.created_at = Time.now
          end

          write(target_file, what.to_yaml)
        end

        def destroy(what)
          log :info, "booking:REMOVE:#{what.ident}"
          rm(repository_path(what.filename), :verbose => true)
        end


        def with_user(user, &blk)
          @user, @events = user, nil
          ret = yield self if block_given?
          ret || self
        end
        
      end

    end

  end

end
