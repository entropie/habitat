module Blog

  module Database

    extend Habitat::Database

    class Adapter

      class File < Habitat::Database::Adapter

        BLOGPOST_EXTENSION = ".post.yaml".freeze

        include Habitat::Mixins::FU

        def initialize(path)
          @path = path
        end

        def path(*args)
          ::File.join(@path, *args)
        end

        def adapter_class(create = false)
          create ? Draft : Post
        end

        def setup
          @setup = true
          log :debug, "setting up adapter directory #{path}"
          FileUtils.mkdir_p(path)
          @setup
        end

        def repository_path(*args)
          ::File.join(::File.realpath(path), "blog", *args)
        rescue Errno::ENOENT
          warn "does not exist: #{path("blog")}"
          path("blog", *args)
        end

        def post_filename(post)
          repository_path(post.slug + BLOGPOST_EXTENSION)
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
          files.push(*fileglob.call("drafts")) if @user
          files.push(*fileglob.call("posts"))
          files
        end

        def posts(user = nil)
          @posts = Posts.new(user || @user).push(*post_files.map{|pfile| load_file(pfile)})
        end

        def by_slug(slug)
          posts.dup.select{|p| p.slug == slug }.first
        end

        def load_file(yamlfile)
          log :debug, "loading #{yamlfile}"
          YAML::load_file(yamlfile)
        end

        def create(param_hash)
          raise NoUserContext, "trying to call #create without valid user context " unless @user

          adapter_class(true).new(self).populate(param_hash)
        end

        def store(post_or_draft)
          raise NoUserContext, "trying to call #store without valid user context " unless @user
          log :info, "blog:STORE:#{post_or_draft.title}"
          retval = post_or_draft.for_yaml
          retval.user_id = @user.id

          unless exist?(post_or_draft)
            FileUtils.mkdir_p(::File.dirname(post_or_draft.filename), :verbose => true)
            FileUtils.mkdir_p(post_or_draft.datadir, :verbose => true)

            unless retval.valid?
              raise Habitat::Database::EntryNotValid, "post not valid #{PP.pp(post_or_draft.for_yaml, "")}"
            end
            retval.filename = post_or_draft.filename
            retval.datadir = post_or_draft.datadir
          end

          unless retval.image.written?
            upload(post_or_draft, retval.image)
          end

          retval.updated_at = Time.now
          write(retval.filename, YAML.dump(retval))
          post_or_draft
        end

        def upload(post, obj)
          post.upload(obj)
        end

        def to_draft(post)
          log :info, "blog:DRAFT:#{post.title}"
          rm(post.filename, :verbose => true)
          store(post.to_draft(self))
        end

        def to_post(draft)
          log :info, "blog:UNDRAFT:#{draft.title}"
          rm(draft.filename, :verbose => true)
          store(draft.to_post(self))
        end

        def destroy(post_or_draft)
          log :info, "blog:REMOVE:#{post_or_draft.title}"
          rm(post_or_draft.filename, :verbose => true)
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
