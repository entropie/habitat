# coding: utf-8
module Felle

  DEFAULT_ADAPTER = :File

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

        def fellclass(type)
          Felle.const_get(type.to_s.capitalize.capitalize)
        end

        def setup
          @setup = true
          log :debug, "setting up adapter directory #{path}"
          FileUtils.mkdir_p(path)
          @setup
        end

        def repository_path(*args)
          ::File.join(::File.realpath(path), "felle", *args)
        rescue Errno::ENOENT
          warn "does not exist: #{path("blog")}"
          path("felle", *args)
        end

        def exist?(fell)
          #::File.exist?(post_filename(post))
        end

        def datadir(*args)
          ::File.expand_path(repository_path("../data", *args))
        end

        def fell_files
          toglob = repository_path + "/**/*.yaml"
          Dir.glob(toglob)
        end

        def select(obj, env = nil)
        end

        def exist?(obj)
        end

        def felle
          fell_files.map {|ff|
            YAML::load_file(ff)
          }
        end

        def load_file(yamlfile)
        end

        def find(slug)
          res = felle.select {|ff| ff.slug == slug }
          res.size == 1 and res.first
        end

        def upload(fell, obj)
          fell.upload(obj)
        end

        def upload_header(fell, obj)
          fell.upload(obj, "header")
        end

        def create(ident, attributes: {}, type: :Hund, state: 0, gender:, birthday:, origin:, breed: "crossbreed", text:)
          clz = fellclass(type).new(ident)
          clz.adapter = self

          clz.attributes = attributes
          clz.gender   = gender
          clz.birthday = birthday
          clz.origin   = origin
          clz.breed    = breed
          clz.state    = state
          clz.text     = text

          clz.root = clz.root
          clz.datadir = clz.datadir
          clz.updated_at = Time.now
          clz
        end

        def update(fell_or_fellident, params)
          fell = fell_or_fellident
          unless fell.kind_of?(Fell)
            fell = find(fell_or_fellident)
          end

          clz = fell
            
          [:attributes, :gender, :birthday, :origin, :breed, :state, :text].each do |t|
            if r = params[t]
              clz.send("#{t}=", params[t])
            end
          end

          clz
        end

        # def update_or_create(ident, param_hash)
        #   snippet = adapter_class(kind).new(ident).extend(SnippetCreater)
        #   store(snippet, content)
        # end

        def store(fell)
          log :info, "felle:STORE:#{fell.slug}"


          text = fell.text
          fell.remove_instance_variable("@text")
          content = fell.to_yaml

          file = fell.yaml_file

          [::File.dirname(file), fell.datadir].each do |ndir|
            FileUtils.mkdir_p(ndir, :verbose => true)             
          end

          write(fell.text_file, text)
          write(file, content)
        end

        def destroy(snippet)
          # log :info, "snippet:REMOVE:#{snippet.ident}"
          # rm(repository_path(snippet.filename), :verbose => true)
        end

        def with_user(user, &blk)
          @user, @felle = user, nil
          ret = yield self if block_given?
          #@user, @posts = nil, nil
          ret || self
        end


      end

    end

  end

end
