module Tumblog
  module Database

    extend Habitat::Database

    class Adapter

      class File < Habitat::Database::Adapter

        BLOGPOST_EXTENSION = ".tpost.yaml".freeze

        include Habitat::Mixins::FU

        def initialize(path)
          @path = path
        end

        def path(*args)
          ::File.join(@path, *args)
        end

        def adapter_class(create = false)
          Post
        end

        def setup
          @setup = true
          log :debug, "setting up adapter directory #{path}"
          FileUtils.mkdir_p(path)
          @setup
        end

        def repository_path(*args)
          ::File.join(path, relative_path(*args))
        rescue Errno::ENOENT
          warn "does not exist: #{path("blog")}"
          path("tumblblog", *args)
        end

        def relative_path(*args)
          ::File.join("tumblblog", *args)
        end

        def post_filename(post)
          repository_path(post.id + BLOGPOST_EXTENSION)
        end

        def exist?(post)
          ::File.exist?(post_filename(post))
        end

        def datadir(*args)
          ::File.expand_path(repository_path("../data", *args))
        end

        def post_files
          fileglob = -> (directory) {
            toglob = repository_path(directory) + "/*" + BLOGPOST_EXTENSION
            Dir.glob(toglob)
          }
          files = []
          files.push(*fileglob.call("entries/*"))
          files
        end

        def by_id(id)
          entries.select{|e| e.id == id}.first
        end

        def entries(user = nil)
          @posts = Entries.new(user || @user).push(*post_files.map{|pfile| load_file(pfile)})
          @posts.reject!{|post| post.private? } unless @user
          @posts
        end

        def load_file(yamlfile)
          #log :debug, "loading #{Habitat.S(yamlfile)}"
          YAML::load_file(yamlfile)
        end

        def create(param_hash)
          raise ::Habitat::Database::NoUserContext, "trying to call #create without valid user context " unless @user

          adapter_class(true).new(self).populate(param_hash)
        end


        def update(post)
          log :info, "updating #{post.id} #{post.filename}"
          write(::File.join(@path, post.filename), post.to_yaml)
          post
        end


        def store(post)
          raise ::Habitat::Database::NoUserContext, "trying to call #store without valid user context " unless @user
          log :info, "tumblog:STORE:#{post.id}"
          retval = post
          post.user_id = @user.id
          post.datadir = post.relative_datadir
          post.filename = post.relative_filename

          #puts post.to_yaml
          unless exist?(post)
            FileUtils.mkdir_p(::File.dirname(post.filename), :verbose => true)
            FileUtils.mkdir_p(post.datadir, :verbose => true)
          else
            post.updated_at = Time.now
          end
          write(::File.join(@path, post.filename), post.to_yaml)
          post
        end

        def upload(post, obj)
          post.upload(obj)
        end

        def destroy(post)
          log :info, "tumblog:REMOVE:#{post.title}"
          rm_rf(path(post.filename))
          rm_rf(path(post.datadir))
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
