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
          ::File.join("data", *args)
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

        def by_template(tmpl)
          posts.dup.select{|p| p.template && p.template.to_sym == tmpl.to_sym }
        end

        def by_tags(tag)
          posts.dup.reject{|p| !p.tags.include?(tag) }
        end


        def load_file(yamlfile)
          log :debug, "loading #{Habitat.S(yamlfile)}"
          YAML::load_file(yamlfile)
        end

        def create(param_hash)
          raise NoUserContext, "trying to call #create without valid user context " unless @user

          adapter_class(true).new(self).populate(param_hash)
        end

        def update_or_create(param_hash)
          raise NoUserContext, "trying to call #create without valid user context " unless @user

          title = Post.make_slug(param_hash[:title])
          post = by_slug(title)

          if post
            updated = post.update(param_hash)
            return updated
          else
            create(param_hash)
          end
        end

        def store(post_or_draft)
          raise NoUserContext, "trying to call #store without valid user context " unless @user
          log :info, "blog:STORE:#{post_or_draft.title}"

          for_yaml = setup_post(post_or_draft)

          for_yaml.updated_at = Time.now

          write(for_yaml.fullpath, YAML.dump(for_yaml))
          FileUtils.mkdir_p(post_or_draft.datapath, :verbose => true)

          content = post_or_draft.content
          write(post_or_draft.datafile, content)

          Habitat.plugin_enabled?(:cache) do
            Cache[:blog_last_modified] = Time.now
            Cache[post_or_draft.slug] = Time.now
          end

          # post_or_draft
          for_yaml
        end

        def setup_post(post_or_draft)

          for_yaml = post_or_draft.for_yaml

          for_yaml.user_id = @user.id unless for_yaml.user_id

          unless exist?(post_or_draft)
            for_yaml.filename = post_or_draft.filename
            for_yaml.datadir = post_or_draft.datadir
          end
          for_yaml
        end

        def upload(post, obj)
          post.upload(obj)
        end

        def to_draft(post)
          log :info, "blog:DRAFT:#{post.title}"
          rm(post.fullpath, :verbose => true)
          store(post.to_draft(self))
        end

        def to_post(draft)
          log :info, "blog:UNDRAFT:#{draft.title}"
          rm(draft.fullpath, :verbose => true)
          store(draft.to_post(self))
        end

        def destroy(post_or_draft, lang = nil)
          if not lang
            log :info, "blog:REMOVE:#{post_or_draft.title}"
            rm(post_or_draft.fullpath, :verbose => true)
          else
            log :info, "blog:LANGUAGE-REMOVE:#{post_or_draft.title}"
            rm(post_or_draft.datapath, :verbose => true)
          end
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
