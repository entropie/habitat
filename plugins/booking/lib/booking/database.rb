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
          warn "does not exist: #{path("booking")}"
          path("booking", *args)
        end

        def events(year: Time.now.strftime("%y"), month: Time.now.strftime("%m"))
          @events = ::Booking::Events.new(self, year: year, month: month).read.sorted
          @events
        end

        def events_all
          events(year: nil, month: nil)
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

        def update(what, params)
          updated = what.update(params)
          store(updated)
          updated
        end

        def find_update_or_create(param_hash)
          slug = param_hash[:slug]
          ev = events_all.by_slug(slug)
          if ev
            return ev
          else
            create(:event, Booking::Events::Event.normalize_params(param_hash))
          end
        end

        def store(what)
          raise NoUserContext, "trying to call #store without valid user context " unless @user
          raise Habitat::Database::EntryNotValid, "#{what.class}#valid? returns not true" unless what.valid?

          log :info, "booking:store:#{what.slug}"

          target_file = repository_path(what.filename)

          if what.exist?
            rm(target_file, verbose: true)
            what.updated_at = Time.now
          else
            mkdir_p(::File.dirname(target_file))
            what.created_at = Time.now
          end

          write(target_file, what.to_yaml)
        end

        def destroy(what)
          log :info, "booking:REMOVE:#{what.slug}"
          rm(repository_path(what.filename), verbose: true)
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
