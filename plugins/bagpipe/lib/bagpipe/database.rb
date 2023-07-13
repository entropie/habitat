module Bagpipe

  module Database

    extend Habitat::Database

    class Adapter

      class File < Habitat::Database::Adapter

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
          ::File.join(::File.realpath(path), "bagpipe", *args)
        rescue Errno::ENOENT
          warn "does not exist: #{path("blog")}"
          path("bagpipe", *args)
        end

        # def datadir(*args)
        #   ::File.join("data", *args)
        # end

        def repository
          Bagpipe::Repository.new(@path)
        end

        def read(*string_path_or_array_of_segments)
          target = [string_path_or_array_of_segments].flatten.join("/")
          repository.read(target)
        end

        def create(param_hash)
          raise NoUserContext, "trying to call #create without valid user context " unless @user
          raise 
        end

        def update_or_create(param_hash)
          raise NoUserContext, "trying to call #create without valid user context " unless @user
          raise
        end

        def store(post_or_draft)
          raise NoUserContext, "trying to call #store without valid user context " unless @user
          raise
        end

        def with_user(user, &blk)
          @user, @posts = user, nil
          ret = yield self if block_given?
          #@user, @posts = nil, nil
          ret || self
        end

      end

    end

  end


end
